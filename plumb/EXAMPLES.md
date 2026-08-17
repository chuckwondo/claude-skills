# Plumb: worked examples

<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->

*One worked example per sounding facet, each a **Problem** and a **Fix** in real
code, taken from a real review run (the full runs are recorded in
[DOGFOOD-LOG.md](DOGFOOD-LOG.md)). Every example is a real fire; none is
invented.*

*Each example names its programming language and its provenance:
**self-authored** (the author's own covjson-msgspec / titiler-covjson work),
**external audit** (a real third-party repo reviewed in review mode), or
**generated fixture** (a sample written quickly, then reviewed). Provenance
matters because an example inherits its source's authority: a fire on external
code proves the probe catches real-world shapes, not a self-plumbed artifact.
For external audits, the source line links to the exact file and line at the
reviewed commit, so a reader can open the original.*

*The code is illustrative: condensed from the cited source to isolate the shape
under review. It is not a verbatim copy, though it is kept close enough that the
linked original is recognizable.*

---

## 1. Correct by construction

### 1a. Make illegal states unrepresentable

Three examples: a lifecycle modeled as a flat bag of independently-settable
fields, an invariant pairing left merely checkable rather than impossible, and a
typestate token expected to hold across a process boundary it cannot cross.

#### Example A (generated: a state machine)

*Java. Generated fixture.*

An order-tracking service stores each order's lifecycle as a free-form `String`
status alongside four independent nullable fields: three timestamps (`paidAt`,
`shippedAt`, `cancelledAt`) and a `trackingNumber`. Each of those four fields is
independently either unset or set, two possibilities, so they allow 2 × 2 × 2 ×
2 = 16 combinations of which fields are present; multiplied by the four possible
status values, the type can represent 4 × 16 = 64 distinct states. Only these
five are legal:

| status | paidAt | shippedAt | trackingNumber | cancelledAt |
| --- | --- | --- | --- | --- |
| NEW | unset | unset | unset | unset |
| PAID | set | unset | unset | unset |
| SHIPPED | set | set | set | unset |
| CANCELLED (before payment) | unset | unset | unset | set |
| CANCELLED (after payment) | set | unset | unset | set |

Every one of the other 59 combinations is nonsense the type nonetheless permits:
a SHIPPED order with no `shippedAt`, a PAID order that already has a
`trackingNumber`, an order that is both PAID and CANCELLED with a `shippedAt`
set. Worse, each field has its own public setter and no transition method checks
the current status first, so those illegal states are not merely representable
but reachable: any setter can fire from any state.

##### Problem

```java
class Order {
    // status and the four fields below are each set independently,
    // by separate public methods
    String status;  // one of "NEW", "PAID", "SHIPPED", "CANCELLED"
    Instant paidAt;
    Instant shippedAt;
    Instant cancelledAt;
    String trackingNumber;

    // no check on the current status before shipping
    void shipOrder(String tracking) {
        this.status = "SHIPPED";
        this.shippedAt = Instant.now();
        this.trackingNumber = tracking;
    }

    void cancelOrder() {
        this.status = "CANCELLED";
        this.cancelledAt = Instant.now();
    }
}
```

Concretely, this sequence is allowed and does the wrong thing:

```java
// status is now CANCELLED
order.cancelOrder();

// no guard, so status flips back to SHIPPED and the customer is
// emailed that their cancelled order has shipped
order.shipOrder("1Z...");
```

The tempting fix is a state check in each method (`if
(status.equals("CANCELLED")) return;`), but that scatters the state machine
across every call site and still leaves all 64 states representable. The
structural fix makes the illegal states impossible to build in the first place:

##### Fix

```java
// each state is its own type, carrying exactly the fields that
// state has
sealed interface OrderState permits New, Paid, Shipped, Cancelled {}

record New() implements OrderState {
    Paid pay(Clock clock) {
        return new Paid(clock.instant());
    }
}

record Paid(Instant paidAt) implements OrderState {
    Shipped ship(Clock clock, String tracking) {
        return new Shipped(paidAt, clock.instant(), tracking);
    }
}

record Shipped(
    Instant paidAt,
    Instant shippedAt,
    String trackingNumber
) implements OrderState {}

record Cancelled(Instant cancelledAt) implements OrderState {}
```

A transition is now a method that returns the next state, and it exists only on
the states it is legal from. `Cancelled` has no `ship` method, so shipping a
cancelled order fails to compile rather than failing in production, and the
illegal rows (a `Paid` order that somehow has a `shippedAt`, a `Cancelled` order
with a tracking number) are simply not constructible.

#### Example B (self: an invariant pairing)

*Python. Self-authored: covjson-msgspec.*

A `Moment` value pairs a timestamp with a precision. The type accepts any
timestamp with any precision, including a timezone-naive timestamp at second
precision, a combination the domain treats as meaningless (a second-level
instant is not well-defined without a zone).

##### Problem

```python
from dataclasses import dataclass
from datetime import datetime
from enum import IntEnum


# ordered coarsest to finest, so a larger value is finer precision
# (SECOND is finer than DAY)
class Precision(IntEnum):
    YEAR = 1
    MONTH = 2
    DAY = 3
    HOUR = 4
    MINUTE = 5
    SECOND = 6


@dataclass
class Moment:
    dt: datetime
    precision: Precision


# both fields are accepted independently, so this nonsensical
# pairing constructs successfully: a sub-day instant with no zone
Moment(naive_datetime, Precision.SECOND)
```

##### Fix

```python
from dataclasses import dataclass
from datetime import datetime


@dataclass
class Moment:
    dt: datetime
    precision: Precision  # the Precision enum from the Problem above

    def __post_init__(self):
        # a sub-day instant (finer than DAY) is ambiguous without a
        # timezone, so reject that pairing at construction
        if self.precision > Precision.DAY and self.dt.tzinfo is None:
            raise ValueError("sub-day precision requires a timezone")
```

In the run where this surfaced it was **parked rather than fixed**: the only
code that builds a `Moment` already upholds the invariant, so no caller can
currently reach the bad state. That makes it a real but non-load-bearing
finding, the kind you name with its cost-and-risk in one line and move on from,
rather than fix immediately. It is a clean illustration of the fix-versus-park
judgment.

*Source: covjson-msgspec `feat/temporal`, 2026-07-07 (self-authored).*

#### Example C (external design: a typestate token across a process boundary)

*Python. External design review: virtualizarr-data-pipelines; the icechunk
mechanism run-verified.*

Typestate stages (`open_store` returns a `Store`, and only a `Store` yields a
`WriteSession`) make an illegal call order uncompilable *within one process*.
But the pipeline runs as separate AWS entrypoints, and a cron-triggered
garbage-collection job is its own process: it never receives a `Store` token, so
it re-derives one through the only constructor it has. That constructor opens the
store with `Repository.open_or_create`, which on an absent store creates a
brand-new empty repository instead of raising, so the GC job silently re-seeds
the exact empty store the typestate was meant to forbid, then garbage-collects
it.

##### Problem

```python
def open_store(cfg) -> Store:
    # create-if-absent: right for the seeding entrypoint, wrong for everyone else
    repo = icechunk.Repository.open_or_create(cfg.storage)
    return Store(repo)


def garbage_collect(cfg) -> None:
    store = open_store(cfg)       # absent store -> CREATES an empty repo...
    store.expire_snapshots(...)   # ...GC now runs against a freshly re-seeded store
```

The typestate stages are honored: `garbage_collect` does hold a real `Store`. The
hole is that `open_store` is the wrong way to obtain one at an entrypoint that is
not allowed to create, and no compile-time token can carry that distinction
across the process boundary.

##### Fix

Give the create capability to the seeding entrypoint alone; every other
entrypoint opens with a raise-on-absent primitive, so a non-creator cannot bring
a store into being:

```python
def seed(cfg) -> Store:              # the only entrypoint that may create
    return Store(icechunk.Repository.open_or_create(cfg.storage))


def open_existing(cfg) -> Store:     # raise-on-absent
    return Store(icechunk.Repository.open(cfg.storage))  # raises if absent


def garbage_collect(cfg) -> None:
    store = open_existing(cfg)       # absent store -> IcechunkError, not a silent re-seed
    store.expire_snapshots(...)
```

A compile-time typestate token lives in memory and does not survive a process or
serialization boundary: a separate entrypoint (a cron job, another Lambda) never
receives it. Across that boundary, re-derive the state from durable storage at
the edge, hand the create capability only to the entrypoint allowed to seed, and
make every non-creator open with a raise-on-absent primitive, never
create-if-absent (which silently re-seeds the state the typestate forbids).

*Source: developmentseed/virtualizarr-data-pipelines redesign dialogue,
2026-07-25 (guide/plan mode; icechunk `open_or_create` vs `open` behavior
run-verified).*

### 1b. Model the domain with types, not primitives

*Python. External audit: earthaccess.*

In the earthaccess library, `login` selects an authentication strategy from a
fixed set of three, but the parameter is typed as a plain `str` and dispatched
by an `if/elif` chain with no final `else`. A value outside the set matches no
branch, and the method returns an unauthenticated session without raising.

#### Problem

```python
# strategy is really a closed set of three, but it is typed str
def login(self, strategy: str = "netrc") -> Any:
    ...
    if strategy == "interactive":
        self._interactive()
    elif strategy == "netrc":
        self._netrc()
    elif strategy == "environment":
        self._environment()
    # no else: an unrecognized strategy falls straight through
    return self
```

A caller who misspells the strategy gets no error at all:

```python
# "netrcc" matches no branch, so login returns an Auth with
# authenticated == False
auth = earthaccess.login(strategy="netrcc")

# the user believes they are logged in, but every later
# authenticated call quietly returns empty results
```

Because `strategy` is a `str`, the checker cannot see that `"netrcc"` is
invalid, and because the `if/elif` has no `else`, the runtime cannot either.
Lifting the parameter to a closed type closes both gaps:

#### Fix

```python
from typing import Literal, assert_never


# a Literal makes the closed set part of the type; the match is
# then typo-proof
def login(
    self,
    strategy: Literal["interactive", "netrc", "environment"] = "netrc",
) -> "Auth":
    match strategy:
        case "interactive":
            self._interactive()
        case "netrc":
            self._netrc()
        case "environment":
            self._environment()
        case _:
            # unreachable for valid input; assert_never turns a
            # typo into a type error
            assert_never(strategy)
    return self
```

The probe is specific, not a blanket ban on string-typed closed sets: it fires
here because `strategy` becomes part of an object's authentication state that
later code trusts. A closed-set string used and discarded on the spot (a token
captured from a regex and consumed on the next line, never stored, never
returned) is not a finding. Tracing the value to its consumer is what separates
the two.

*Source: [earthaccess/auth.py#L111-L153][src1] @ bbbced0b (external,
2026-07-21).*

### 1c. Model outcomes as typed values

*Python. External audit: titiler-cmr.*

In titiler-cmr, a temporal query string can be an instant or an interval, but
`parse_datetime` returns all cases as one `tuple` of three optional datetimes,
`(instant, start, end)`, encoding the outcome as *which of the three slots
happen to be set*. Nothing forces a consumer to handle every case, and one
consumer forgets the open-interval case and crashes.

#### Problem

```python
# the return type encodes an Instant-or-Interval choice as
# "which optionals are set"
def parse_datetime(
    s: str,
) -> tuple[datetime | None, datetime | None, datetime | None]:
    # returns (instant, start, end)
    ...
```

An interval that is open at the start (a documented, legal input) sets only the
third slot:

```python
# "/2018-03-18T12:31:12Z" is an open-start interval, so it
# returns (None, None, end)
instant, start, end = parse_datetime("/2018-03-18T12:31:12Z")


# a downstream consumer assumes one of the first two slots is
# always set
def interpolated_xarray_ds_params(datetime_, start, end):
    # dt is None here, because only end was set
    dt = datetime_ if datetime_ else start

    # AttributeError: 'NoneType' has no attribute 'isoformat',
    # an HTTP 500 on a legal request
    return dt.isoformat()
```

A guard at the crash site would be the wrong fix, because the same weak return
type also causes this consumer to silently drop `end` on the ordinary
closed-interval path. The real fix is to make the two outcomes distinct types at
the boundary, so no consumer can destructure them wrongly:

#### Fix

```python
from dataclasses import dataclass
from datetime import datetime


# the choice is now an explicit, closed set of two named cases
@dataclass
class Instant:
    at: datetime


@dataclass
class Interval:
    start: datetime | None
    end: datetime | None


Temporal = Instant | Interval


# parse_datetime returns the sum, so the outcome is never ambiguous
def parse_datetime(s: str) -> Temporal:
    ...
```

The consumer that used to crash now matches on the case, and the
compiler-visible cases mean it can no longer reach for a slot that was not set:

```python
# the same consumer, rewritten against Temporal instead of the
# three-optional tuple
def interpolated_xarray_ds_params(temporal: Temporal):
    match temporal:
        case Instant(at):
            dt = at
        case Interval(start, end):
            # both ends are explicit; end is no longer silently
            # dropped, and there is no unhandled None to crash on
            dt = start or end
    return dt.isoformat()


# the input that used to 500 now returns Interval(None, <end>),
# and the Interval arm handles it
interpolated_xarray_ds_params(parse_datetime("/2018-03-18T12:31:12Z"))
```

*Source: [titiler/cmr/utils.py#L76][src2] (the weak return) and
[dependencies.py#L307][src3] (the crashing consumer) @ 5101ef06 (external,
2026-07-21; the failure was constructed and run).*

### 1d. Totality: handle every case

*Java, with a Go note. Generated fixtures.*

A status-description method in the generated order service handles three
statuses explicitly and lets a bare `return` catch everything else, so any
status it does not know about, including one added later, silently reports as
"Cancelled".

#### Problem

```java
String describeStatus(Order o) {
    if (o.status.equals("NEW")) {
        return "Pending";
    }
    if (o.status.equals("PAID")) {
        return "Awaiting shipment";
    }
    if (o.status.equals("SHIPPED")) {
        return "In transit";
    }
    // bare default: an unknown or newly-added status silently
    // reads as "Cancelled"
    return "Cancelled";
}
```

Matching on a closed type instead makes the compiler enforce that every case is
handled, so adding a new state forces this code to be updated:

#### Fix

```java
String describe(OrderState s) {
    // exhaustive switch over the sealed type: adding a permitted
    // subtype that is not handled here becomes a compile error
    return switch (s) {
        case New n -> "Pending";
        case Paid p -> "Awaiting shipment";
        case Shipped sh -> "In transit";
        case Cancelled c -> "Cancelled";
    };
}
```

#### Note: the guarantee is language-dependent

"Adding a case forces the update" assumes a checker that enforces
exhaustiveness. Error-value languages do not provide one. In Go, discarding an
error compiles cleanly and `go vet` stays silent:

```go
// the error is discarded with _, and neither the compiler nor
// `go vet` complains
amt, _ := parseAmount(os.Args[2])
```

For error-values (Go, C return codes, unchecked exceptions), totality is not a
compiler guarantee but a discipline, enforced only by an opt-in linter such as
`errcheck` or `staticcheck`, or not at all. Name it as a discipline in those
languages, not as a property the types uphold.

*Source: gen-2 Java order-lifecycle (generated); gen-3 Go `spend` CLI,
2026-07-21 (generated, the language-flip case).*

### 1e. Sound typing: no lies to the checker

*Python. External audit: earthaccess.*

An earthaccess type alias unions a `Literal` of parser names with `Any`. Because
`Any` is compatible with everything, the union collapses back to `Any`, and the
`Literal` constrains nothing: the annotation looks precise but tells the checker
nothing.

#### Problem

```python
from typing import Any, Literal

# earthaccess/virtual/_types.py
ParserType = (
    Literal[
        "DMRPPParser",
        "HDFParser",
        "NetCDF3Parser",
        "KerchunkJSONParser",
        "KerchunkParquetParser",
    ]
    # the | Any widens the whole union back to Any, so the
    # Literal above constrains nothing
    | Any
)
```

#### Fix

```python
from typing import Literal, Protocol


# name what the non-literal case actually is: a parser object
# with a known interface
class ParserProtocol(Protocol):
    def parse(self, granule) -> Manifest:
        ...


ParserType = (
    Literal[
        "DMRPPParser",
        "HDFParser",
        "NetCDF3Parser",
        "KerchunkJSONParser",
        "KerchunkParquetParser",
    ]
    | ParserProtocol
)
```

#### Narrowing facet: a stricter predicate needs TypeGuard, not TypeIs

A related soundness trap appears when a type-narrowing predicate is *stricter*
than the type it narrows. `_is_polygon_array` rejects the empty tuple, but the
empty tuple is still a `tuple`:

```python
from typing import TypeGuard


# use TypeGuard, not TypeIs, because this predicate is stricter
# than tuple
def _is_polygon_array(v: tuple) -> TypeGuard[PolygonArray]:
    return len(v) > 0 and all(_is_ring(r) for r in v)
```

With `TypeIs`, the checker would narrow the *else* branch by subtracting
`PolygonArray` from `tuple`, and conclude that an empty `()` is not a `tuple`,
which is false. `TypeGuard` narrows only the positive branch, so it stays sound
when the predicate does not cover the whole input type.

#### Specificity: where it correctly stays quiet

Not every `Any` is a lie. Elsewhere titiler-cmr annotates a value `cache_client:
Any` at a genuine dynamic boundary (an object with no useful static type), and
the probe correctly stays silent there. The fire is an `Any` or cast that
*defeats a type the code otherwise declares*, not one that sits honestly at a
boundary where no better type exists.

Nor is every lookup table. Both forms below live in one file. The first is a
lie, because its values are a union of `type[...]` *consumed as a type
argument*: no single `_ScalarT` binding fits the union, so the checker settles
on `None` and then checks every downstream expression against the wrong element
type, in green.

```python
# covjson-msgspec #110, proposed and rejected
_PROJECTION: Final = {"float": float, "integer": int, "string": str}

# reveal_type -> tuple[None, ...], and mypy --strict reports success,
# for a tuple that holds floats at runtime
projected = self.values_as(_PROJECTION[self.data_type])
```

The second is sound, and 1e correctly stays quiet on it: the values are
homogeneous callables, the key type is annotated, and nothing is consumed as a
type argument, so the table keeps the exhaustiveness a `match` would give.

```python
# covjson_msgspec/range.py, accepted in the same file
_CONVERTERS: Final[
    Mapping[Literal["float", "integer", "string"], Callable[[Any], _Scalar | None]]
] = {"float": _float_or_none, "integer": int, "string": str}

# a fourth dataType fails at the index site, not at runtime:
#   Invalid index type "Literal['float', 'integer', 'string', 'boolean']"
#   ... expected type "Literal['float', 'integer', 'string']"  [index]
convert = _CONVERTERS[data_type]
```

*Source: [earthaccess/virtual/_types.py#L10-L19][src4] @ bbbced0b (external,
2026-07-21); the narrowing case from covjson-msgspec #138 (self-authored); the
lookup-table contrast from covjson-msgspec #110 / PR #188 (self-authored, both
forms verified by running `mypy --strict`).*

---

## 2. One source of truth

*Python. Self-authored: covjson-msgspec.*

In the covjson-msgspec OpenAPI bridge, the members of the top-level
`CoverageJSON` union are listed once in the union itself and then a second time,
by hand, in a `_ROOT_TYPES` tuple that several functions iterate over. The two
lists encode the same fact and can drift apart.

### Problem

```python
# the authoritative membership of the top-level union
CoverageJSON = Coverage | CoverageCollection | Domain | Parameter

# the same membership, hand-copied into a second home
_ROOT_TYPES = (Coverage, CoverageCollection, Domain, Parameter)
```

Add a fifth member to `CoverageJSON` and forget to update `_ROOT_TYPES`, and the
failure is silent: `component_schemas()` iterates `_ROOT_TYPES` and simply omits
the new type, while `schema_ref` (typed against the union) emits a `$ref`
pointing at the now-missing schema. Worse, the test that checks the emitted
surface is pinned to the same hand-written list, so it agrees with the bug
instead of catching it.

### Fix

```python
# get_args(X | Y | Z) returns (X, Y, Z), the union's members
from typing import get_args

# derive the list from the union, so there is exactly one source
# of truth
_ROOT_TYPES = get_args(CoverageJSON)
```

Now adding a union member updates `_ROOT_TYPES` automatically. A side benefit:
the module no longer needs to import each member by name, only the union, which
also lowers its coupling.

### Rider: a thin convenience over a complete core

The same review affirmed a related, healthy shape worth naming. A one-line
convenience wrapper was layered over the full API, with the full API still
directly reachable for the cases the shortcut does not cover. This "trivial
common path over a complete core" only ever showed up as something to affirm,
never as a finding to fix, which is why it rides alongside one-source-of-truth
rather than standing as its own sounding. It describes the *shape of the public
face* of the single source: a thin shortcut that does not lock anyone out of the
complete form underneath.

*Source: covjson-msgspec #14 implementation, 2026-07-08 (self-authored).*

---

## 3. Focused parts, clean seams

### 3a. Low coupling, clean boundaries

*Python. External audit: zarr-python.*

In zarr-python, a function in the array-metadata module reaches upward into the
codec layer and hides the resulting import cycle behind a function-local (lazy)
import. This is an established, load-bearing pattern in the codebase, so a
review that judges code against its neighbors would pass it. Judged against the
ideal, the direction of the dependency is inverted, and the code's own TODO
comment nearby already says so.

#### Problem

```python
# in zarr/core/metadata/v3.py, the array-metadata module
def validate_codecs(codecs, dtype) -> None:
    # a lazy import reaching up into the codecs layer, which
    # papers over a metadata-to-codecs import cycle
    from zarr.codecs.sharding import ShardingCodec

    abc = validate_array_bytes_codec(codecs)
    while isinstance(abc, ShardingCodec):
        abc = validate_array_bytes_codec(abc.codecs)
```

#### Fix

The body does not change; what changes is *where the function lives*. It moves
out of the metadata module and into the codecs layer that already owns
`ShardingCodec`:

```python
# MOVED into zarr/codecs/, the layer that already owns
# ShardingCodec. From its own layer the import is an ordinary
# top-level one, so there is no cycle left to hide.
from zarr.codecs.sharding import ShardingCodec


def validate_codecs(codecs, dtype) -> None:
    abc = validate_array_bytes_codec(codecs)
    while isinstance(abc, ShardingCodec):
        abc = validate_array_bytes_codec(abc.codecs)
```

```python
# zarr/core/metadata/v3.py now imports nothing from codecs.
# The array-creation path, which already depends on both layers,
# is what calls validate_codecs.
```

The lazy import existed only because `metadata` and `codecs` imported each
other: a top-level `from zarr.codecs...` inside the metadata module would have
been a circular import, so it was deferred to call time to compile. Relocating
the function removes the metadata-to-codecs dependency entirely, which dissolves
the cycle, so the import can be an honest top-level one and the deferral is no
longer needed. The fix is the move, not a rewrite of the logic.

*Source: [src/zarr/core/metadata/v3.py#L96][src5] @ 13279cac (external,
2026-07-10/11, brownfield).*

### 3b. Encapsulation: expose intent, hide representation

*Python. External audit: earthaccess.*

In earthaccess, the domain object returned to users *is* the raw CMR JSON:
`DataGranule` subclasses `dict`, so callers index into the storage format
directly. That coupling to the raw shape is not local; the same nested indexing
appears across six modules, so any change to the CMR layout breaks all of them.

#### Problem

```python
# the domain object is literally the raw CMR UMM JSON
class DataGranule(CustomDict):
    def get_umm(self, key) -> str | dict[str, Any]:
        ...


# callers reach into the raw storage layout directly, and this
# same pattern repeats across six modules
geometry = granule["umm"]["SpatialExtent"]["HorizontalSpatialDomain"]
```

#### Fix

```python
from dataclasses import dataclass


# parse the raw JSON into a typed model at the boundary, and
# expose intent, not storage
@dataclass
class DataGranule:
    spatial_extent: SpatialExtent

    # callers ask for what they mean; the storage layout stays
    # private and can change freely
    @property
    def geometry(self) -> Geometry:
        return self.spatial_extent.horizontal.geometry
```

Callers now depend on `granule.geometry`, an operation named for what it means,
rather than on a chain of string keys that mirrors the wire format. The
representation can change without touching any caller.

*Source: [earthaccess/results.py#L323][src6] (`DataGranule`, subclassing
`CustomDict` at L25) @ bbbced0b (external, 2026-07-21).*

### 3c. Cohesion: one concern per unit

*Java. Generated fixture.*

A single `OrderService` in the generated sample does placing, paying, shipping,
cancelling, and describing orders. You cannot state its job without listing five
things joined by "and", the tell of a unit that has taken on more than one
concern.

#### Problem

```java
// one class doing five separable jobs
class OrderService {
    Long placeOrder(Cart cart, Tier tier) { ... }
    boolean payOrder(long id) { ... }
    boolean shipOrder(long id, String tracking) { ... }
    boolean cancelOrder(long id) { ... }
    String describeStatus(Order o) { ... }
}
```

#### Fix

```java
// split by concern; each unit has a single, nameable job

// pricing: a pure function of the cart and tier
class OrderPricing {
    Money price(Cart cart, Tier tier) { ... }
}

// persistence: load and save orders
class OrderRepository {
    Order load(long id);
    void save(Order order);
}

// pay/ship/cancel are deliberately NOT here: they are transitions
// on the OrderState types (see the first example), where an
// illegal transition cannot compile. describeStatus lives on the
// order itself (the next facet). What is left for a thin
// application service is orchestration only: load, apply the
// state transition, save.
```

The split does not reintroduce the ordering hazard the first example removed.
The transitions stay on the state types, so "cancel then ship" is still
un-expressible: `Cancelled` has no `ship` method, and no service here takes a
bare `OrderState` and lets any transition run on it. Cohesion and correct-by-
construction reinforce each other rather than pulling apart.

*Source: gen-2 Java order-lifecycle service, 2026-07-20 (generated).*

### 3d. Keep behavior near the data it uses most

*Java. Generated fixture.*

`describeStatus` lives on the service, but every field it touches belongs to the
`Order` it is passed; it reads nothing from the service itself. It is a method
sitting on the wrong object, reaching across a boundary for data another type
owns.

#### Problem

```java
class OrderService {
    // reads o.getStatus(), o.getShippedAt(), and nothing
    // from `this`
    String describeStatus(Order o) {
        if (o.getStatus().equals("SHIPPED")
                && o.getShippedAt() != null) {
            return "In transit";
        }
        if (o.getStatus().equals("PAID")) {
            return "Awaiting shipment";
        }
        return "Pending";
    }
}
```

#### Fix

```java
class Order {
    // the behavior now lives with the data it uses; callers tell
    // the order to describe itself
    String describe() {
        if (this.status.equals("SHIPPED")
                && this.shippedAt != null) {
            return "In transit";
        }
        if (this.status.equals("PAID")) {
            return "Awaiting shipment";
        }
        return "Pending";
    }
}
```

Moving the method onto `Order` (or, better, onto each `OrderState` record, which
would also make it exhaustive) turns a reach-across into a local computation.

*Source: gen-2 Java order-lifecycle service, 2026-07-20 (generated).*

### 3e. Command-Query Separation: ask or do, not both

*Python. External audit: earthaccess.*

`DataGranule.__repr__` looks like a pure query (it returns a string for
display), but it writes into the record as a side effect: when a key is missing
it inserts it with a value of `None`. Calling `repr()` on a granule therefore
changes the granule, which also silently breaks the record's faithfulness to the
original CMR data.

#### Problem

```python
def __repr__(self) -> str:
    ...
    # a query that mutates: it inserts the key when it is missing
    if "SpatialExtent" not in self["umm"]:
        self["umm"]["SpatialExtent"] = None
    return f"""
    Collection: {self["umm"]["CollectionReference"]}
    Spatial coverage: {self["umm"]["SpatialExtent"]}
    ...
    """
```

The consequence is subtle and order-dependent:

```python
# before repr, "SpatialExtent" is genuinely absent from the
# record
"SpatialExtent" in granule["umm"]  # False

# for display only, or so the caller assumes
repr(granule)

# after repr, the key exists with an explicit None, so the
# record no longer round-trips
"SpatialExtent" in granule["umm"]  # True
```

Any consumer that distinguishes "key absent" from "key present but null", such
as a validator or a serializer re-emitting the UMM record, now sees a different
record purely because something called `repr()` on it. The fix is to make the
query pure:

#### Fix

```python
def __repr__(self) -> str:
    ...
    # read without mutating: .get returns None for a missing key
    # but inserts nothing into the record
    extent = self["umm"].get("SpatialExtent")
    return f"""
    Collection: {self["umm"]["CollectionReference"]}
    Spatial coverage: {extent}
    ...
    """
```

The only change from the original is the missing-key handling: the mutating `if
... not in ...: self[...] = None` becomes a non-mutating `.get`. The displayed
string is unchanged (a missing extent still prints as `None`), but the record is
left exactly as it was found.

The probe is discriminating, not firing on any method that does work: elsewhere,
in titiler-cmr, a `bounds` property performs a network fetch but does not mutate
the object, and it correctly did not fire (a query with an I/O cost is not a
query that commands).

*Source: [earthaccess/results.py#L358-L369][src7] @ bbbced0b (external,
2026-07-21; the run designed to exercise CQS).*

---

## 4. Functional core, effects at the edges

*Python. External audit: titiler-cmr.*

titiler-cmr injects its effects well in most places (the CMR client, the dataset
opener, and the S3 credentials are all passed in), which makes the exceptions
stand out. A token provider reaches directly for two effects it should receive
instead: it reads the wall clock in its validity check, and constructs an HTTP
client inline in `_fetch`. The 135 mock references in the test suite are the
symptom, each one standing in for an effect the code grabbed rather than
accepted.

### Problem

```python
# titiler/cmr/credentials.py
from httpx2 import Client


class EarthdataTokenProvider:
    def _is_valid(self) -> bool:
        ...
        # reaches for the wall clock
        return self._expires_at > datetime.now(UTC) + BUFFER

    def _fetch(self) -> None:
        # constructs the HTTP client inline instead of receiving it
        with Client() as client:
            response = client.post(TOKEN_URL, auth=self._creds)
            ...
```

To test token refresh against this, you have to patch `httpx2` *and* freeze
`datetime.now`, because both effects are reached for inside the object. Passing
them in removes the need for either patch:

### Fix

```python
from collections.abc import Callable


class EarthdataTokenProvider:
    def __init__(self, client: Client, now: Callable[[], datetime]):
        # the client and the clock are injected, not reached for
        self._client = client
        self._now = now

    def _is_valid(self) -> bool:
        return self._expires_at > self._now() + BUFFER

    def _fetch(self) -> None:
        response = self._client.post(TOKEN_URL, auth=self._creds)
        ...
```

A test now passes a stub client and a fixed `now`, with no patching at all. This
is the same dependency injection the codebase already uses for its CMR client
and dataset opener; these two seams were simply missed. The wall of mocks in the
tests was the tell that an effect had been reached for rather than injected:
testability without mocks is a symptom of this sounding, not a separate one.

*Source: [titiler/cmr/credentials.py#L61][src8] (inline `Client()`; the clock is
read at L58) @ 5101ef06 (external, 2026-07-21).*

---

## 5. Faithful round-trips

### 5a. Faithfulness: preserve the input

*Python. Self-authored: titiler-covjson.*

A titiler-covjson plan modeled a point sample's data with a phantom trailing
axis, shape `(bands, 1)`, when a point sample is really one value per band,
shape `(bands,)`. The extra axis is not in the data; it was invented by the
model, and every downstream step then has to work around it.

#### Problem

```python
from dataclasses import dataclass


@dataclass
class PointInput:
    # shape (bands, 1): the trailing 1 is a phantom axis the data
    # does not have
    data: NDArray


def to_coverage(inp: PointInput) -> Coverage:
    # 1. a reshape, needed only to undo the invented axis
    values = inp.data.reshape(inp.data.shape[0])

    # 2. a guard, needed only to defend the invented axis
    assert inp.data.shape[1] == 1

    # 3. a comment defending the shape, the surest tell that the
    #    shape is wrong: "WARNING: do not simplify this away"
    ...
```

One invented axis produces four separate consequences: a reshape, a shape guard,
a warning comment, and a `(2, 3)`-shaped test case built to match the wrong
shape. Storing the honest shape dissolves all of them:

#### Fix

```python
from dataclasses import dataclass


@dataclass
class PointInput:
    # shape (bands,): exactly what a point sample is
    data: NDArray


def to_coverage(inp: PointInput) -> Coverage:
    # no reshape, no guard, no defensive comment
    values = inp.data
```

The tell here is worth remembering on its own: **a comment that defends a data
shape ("do not simplify this away") is usually evidence that the shape is
unfaithful to the data.**

Why did the phantom axis get there in the first place? A downstream consumer
indexed a single band with `data[i]`, and integer-indexing a 1-D masked array
returns a bare `float32`, dropping the mask. The `(bands, 1)` shape was added so
that `data[i]` returns a 1-element array instead of a scalar, papering over
that. Running the actual read is what exposed the real answer: on the honest
`(bands,)` shape, a *slice* `data[i:i+1].reshape(())` returns a proper masked
0-D value, so the mask is preserved without any extra axis. The axis was
compensating for the wrong indexing, not for anything in the data.

That is why the one-line simplification fixes everything at once: all four
workarounds (the reshape, the `shape[1] == 1` guard, the "do not simplify"
comment, and the `(2, 3)` test) existed only to service the invented axis.
Remove the axis and switch the consumer from `data[i]` to a slice, and there is
nothing left for any of them to do. The fix was found by running the read, not
by rereading the model, because the model and its docstring both looked correct.

*Source: titiler-covjson #44 plan, 2026-07-09 (self-authored).*

### 5b. Symmetry: complete the pair

*Python. External audit: zarr-python.*

Two sibling classes in zarr-python parse themselves from a dict.
`ArrayV3Metadata.from_dict` implements the v3 rule for unknown extension fields
(allow them only if they carry `must_understand: false`);
`GroupMetadata.from_dict` filters unknown keys only for v2 and has no v3
handling at all. The result is that a v3 group carrying a legal extension
crashes, and the gap is invisible if you review either class on its own.

#### Problem

```python
from collections.abc import Mapping
from dataclasses import dataclass, field, fields


# zarr/core/metadata/v3.py: a dataclass WITH a field to hold
# allowed extensions; from_dict validates unknown keys and stores
# the allowed ones in that field
@dataclass(frozen=True)
class ArrayV3Metadata:
    shape: tuple[int, ...]
    codecs: tuple
    # ...other array fields...
    extra_fields: dict = field(default_factory=dict)

    @classmethod
    def from_dict(cls, data):
        data = dict(data)
        # ...known structural keys (zarr_format, node_type) popped...
        allowed = {}
        for key in set(data) - ARRAY_FIELD_KEYS:
            val = data.pop(key)
            # a v3 extension is a mapping with must_understand=False
            if isinstance(val, Mapping) and val.get("must_understand") is False:
                allowed[key] = val
            else:
                raise TypeError(f"disallowed extra field: {key!r}")
        # the allowed extensions are stored in the dedicated field
        return cls(**data, extra_fields=allowed)


# zarr/core/group.py: a dataclass with NEITHER an extra-fields
# field NOR any v3 extension handling
@dataclass
class GroupMetadata:
    attributes: dict = field(default_factory=dict)
    zarr_format: int = 3

    @classmethod
    def from_dict(cls, data):
        data = dict(data)
        data.pop("node_type", None)
        zarr_format = data.get("zarr_format")
        if zarr_format == 2 or zarr_format is None:
            # only v2 drops unknown keys; v3 is not handled at all
            keep = {f.name for f in fields(cls)}
            data = {k: v for k, v in data.items() if k in keep}
        # for v3, unknown keys survive, and there is no field to
        # hold them, so they hit the constructor below
        return cls(**data)
```

A spec-legal v3 group that carries an extension crashes on that final
`cls(**data)`:

```python
# a v3 group carrying a must_understand extension is spec-legal
doc = {
    "zarr_format": 3,
    "node_type": "group",
    "my_ext": {"must_understand": False},
}

# zarr_format == 3, so from_dict skips the filter and calls
# cls(zarr_format=3, my_ext={...}). GroupMetadata has no my_ext
# field, so its generated __init__ rejects the keyword:
GroupMetadata.from_dict(doc)
# TypeError: __init__() got an unexpected keyword argument 'my_ext'
```

The blast radius is external: any v3 group with an extension, written by any
implementation, is unopenable by this reader, against an explicit spec MUST. The
fix is to share the handling so the pair is symmetric:

#### Fix

```python
from collections.abc import Mapping
from dataclasses import dataclass, field, fields


# one shared helper, called by BOTH from_dict methods, so the v3
# extension rule lives in one place. It splits a dict into the
# known fields and the allowed extensions (mappings with
# must_understand=False), and raises on anything else.
def split_v3_extensions(
    data: dict, known: set[str]
) -> tuple[dict, dict]:
    core, extras = {}, {}
    for key, val in data.items():
        if key in known:
            core[key] = val
        elif isinstance(val, Mapping) and val.get("must_understand") is False:
            extras[key] = val
        else:
            raise TypeError(f"disallowed extra field: {key!r}")
    return core, extras


# array side: same behavior, now sourced from the shared helper
class ArrayV3Metadata:
    @classmethod
    def from_dict(cls, data):
        data = dict(data)
        # ...structural keys (zarr_format, node_type) popped first...
        known = {f.name for f in fields(cls)} - {"extra_fields"}
        core, extras = split_v3_extensions(data, known)
        return cls(**core, extra_fields=extras)


# group side: GAINS an extra_fields field so it too can hold
# extensions, and routes through the SAME helper, so the pair is
# now symmetric
@dataclass
class GroupMetadata:
    attributes: dict = field(default_factory=dict)
    zarr_format: int = 3
    extra_fields: dict = field(default_factory=dict)

    @classmethod
    def from_dict(cls, data):
        data = dict(data)
        data.pop("node_type", None)
        known = {f.name for f in fields(cls)} - {"extra_fields"}
        core, extras = split_v3_extensions(data, known)
        return cls(**core, extra_fields=extras)
```

Completing the pair takes two matched changes: the shared helper (so the
extension *rule* has one home), and the `extra_fields` field on `GroupMetadata`
(so the group side has somewhere to *put* an accepted extension, which is what
`ArrayV3Metadata` already had). With both, a legal extension is stored on either
class and an illegal extra raises identically on both. The reusable move: when
two types implement the same external rule, compare each against the *rule*, not
just against each other, because the missing half is invisible when you look at
either class alone.

*Source: [ArrayV3Metadata.from_dict, v3.py#L612][src9] versus
[GroupMetadata.from_dict, group.py#L413][src10] @ 13279cac (external,
2026-07-10/11).*

---

## 6. Match strictness to the requirement

*Python. Self-authored repo (covjson-msgspec); an external contributor's patch.*

A contributor's patch enforced a rule as a hard error, citing the spec as saying
the field "MUST" match. The spec actually says "MAY". The false "MUST" was not
invented by the contributor; it was copied faithfully from the project's own
issue, which had paraphrased the spec wrongly. The patch conformed perfectly to
a bad source.

### Problem

```python
def check_domain_type(member, collection):
    # the docstring claims MUST; the spec text actually says MAY
    """Per spec section 6.1.1, domainType MUST match the
    collection's."""
    if member.domain_type != collection.domain_type:
        # enforced as a hard error, which over-states the
        # requirement
        raise ConformanceError(...)
```

### Fix

```python
def check_domain_type(member, collection):
    # verified against the spec text at a pinned revision: the
    # requirement is MAY, not MUST
    """domainType MAY be declared per member (covjson spec
    section 6.1.1)."""
    # a differing per-member type is worth a warning, not an error
    if (
        member.domain_type is not None
        and member.domain_type != collection.domain_type
    ):
        warnings.warn(...)
```

Two lessons ride along. First, the source of a citation must be opened and read,
not recalled: the patch was faithful to the issue but the issue was wrong, so
the fix belongs upstream in the issue as well as in the code. Second, a source
governs a field's *type*, not only a rule's severity. Reading the spec text
directly (rather than a one-line paraphrase of it) showed the composite
coordinate list may be either `[t, x, y, z]` or `[t, x, y]`, a choice a single
fixed-length tuple type cannot represent and would wrongly reject on a
conformant 3-D document.

*Source: covjson-msgspec PR #130, 2026-07-16 (external contributor's patch); the
type-shape lesson from #139, 2026-07-19 (self-authored).*

---

## 7. Names encode shape

*Python. Self-authored: covjson-msgspec.*

In CoverageJSON, a `CoverageCollection` may declare a `domainType` (such as
`Grid` or `PointSeries`) that all its member coverages share. A member may then
omit its own `domainType` and inherit the collection's, or restate the same
value. Restating it is harmless *redundancy*. Declaring a *different* value is a
contradiction the spec forbids. A validation pass reports both situations, but
with a single issue type whose name, `CoverageRedundantDomainType`, is true for
only the first.

### Problem

```python
# both situations are reported with the same issue type and the
# same WARNING severity
class CoverageRedundantDomainType(Issue):
    severity = WARNING


def check_member_domain_type(member, collection):
    if member.domain_type is None:
        return  # omitted: the member inherits the collection's type
    # a member that RESTATES the type is redundant (harmless); one
    # that declares a DIFFERENT type is a spec contradiction. both
    # emit the same issue, so the two cannot be told apart:
    emit(CoverageRedundantDomainType(member))
```

Because both share the reassuring name and a WARNING severity, a consumer that
treats warnings as advisory downgrades the real contradiction, and a run
configured to surface only errors never sees it at all:

```python
# blocks only on errors; a contradiction filed as a WARNING slips
# through as advisory noise
blocking = [i for i in validate(doc) if i.severity is ERROR]
```

### Fix

```python
# two names, each true to its shape, each with the right severity
class DomainTypeNotOmitted(Issue):
    # member repeats the collection's type: harmless
    severity = WARNING


class DomainTypeConflict(Issue):
    # member declares a different type: a contradiction
    severity = ERROR
```

Splitting the name splits the severity correctly, and the contradiction can no
longer hide behind a word that says it is harmless.

A second, smaller instance of the same principle from another run: a year-0000
date was labeled `Unrepresentable` when it was actually `Malformed` (the year is
fine; the month, 13, is not). That name lied about the case, and the lie let the
value slip past a validation pass that keys off the label.

*Source: covjson-msgspec #37 plan, 2026-07-08 (self-authored); the year-0000
mislabel from the 2026-07-07 run.*

---

## 8. Put each check where it belongs

*Python. External audit: titiler-cmr.*

An `Asset` model in titiler-cmr requires three fields at construction, which is
the right instinct: a one-href asset is meaningless, so make it unrepresentable.
But the fields are assembled incrementally from two *independent* sources, and a
legal input provides only one of them, so a valid granule fails to construct and
returns a 500. The invariant is correct; it is just enforced one tier too early.

### Problem

```python
class Asset(BaseModel):
    # all three required, so a one-href asset cannot be built
    direct_href: str
    external_href: str
    ext: str


def get_assets(self):
    ...
    # the three fields come from two independent kinds of
    # related URL
    for ru in related_urls:
        if ru.type == "GET DATA VIA DIRECT ACCESS":
            data["ext"] = extension
            data["direct_href"] = ru.url
        elif ru.type == "GET DATA":
            data["external_href"] = ru.url

    # an HTTPS-only granule (legal in CMR, no S3 direct link) is
    # missing direct_href and ext, so this raises ValidationError,
    # an HTTP 500 on a legal granule
    return {key: Asset(**data) for key, data in assets.items()}
```

The construction-time invariant assumes information the assembly cannot
guarantee is present. Relaxing the constructor and checking completeness where
the whole picture is available fixes it:

### Fix

```python
from pydantic import BaseModel, model_validator


class Asset(BaseModel):
    # relaxed from all-three-required: a granule may expose only
    # S3 (direct_href + ext) or only HTTPS (external_href)
    direct_href: str | None = None
    external_href: str | None = None
    ext: str | None = None

    @model_validator(mode="after")
    def _require_an_href(self):
        # the real invariant, always checkable from the asset's own
        # fields, so it stays at construction (a pydantic after-
        # validator is the BaseModel equivalent of __post_init__):
        # an asset with no access URL at all is meaningless
        if self.direct_href is None and self.external_href is None:
            raise ValueError("asset needs a direct or external href")
        return self


# get_assets is unchanged; an HTTPS-only granule now builds an
# Asset with just external_href, and no longer 500s
```

The relaxation is not a free-for-all. The all-three-required rule was the *wrong
invariant*, not merely the right invariant at the wrong tier: it rejected legal
granules that expose only one access method. The correct *local* invariant, that
an asset has at least one usable href, is always true and checkable from the
asset's own fields, so it stays at construction. What did not belong there was
the completeness *expectation* baked into "all three": whether a deployment
requires an S3 direct link is context the constructor does not have, so if that
must be enforced it belongs in the caller that knows the context. Cheap
always-true invariant at construction; context-dependent policy in the tier that
has the context.

The same principle can run the other way. In a covjson-msgspec design the ideal
was the opposite move: keep the decoded core deliberately permissive (so a
slightly-nonconformant document still loads), and make the illegal states
unrepresentable only at the point of *use*, through an opt-in projection to
clean per-case types. Whether an invariant belongs at construction or at a later
pass depends on where the information to check it actually exists.

*Source: [titiler/cmr/models.py#L181][src11] (`Asset`) and [#L416][src12]
(`get_assets`) @ 5101ef06 (external, 2026-07-21); the permissive-core inverse
from covjson-msgspec #113 (self-authored).*

---

## 9. Reversibility: one-way vs two-way doors

*Python. External audit: zarr-python.*

zarr-python's rectilinear chunk-grid spec encodes a dimension's chunks as a bare
int, a list of ints, or `[value, count]` run-length-encoded pairs. That RLE
encoding is a fresh wire format, not in a released version of the spec. Right
now it is a two-way door: nothing in the wild uses it, so it can still change.
The moment data written in this format exists in the wild, it becomes a one-way
door, because every existing reader would break if the format then changed.

### Problem

```python
# zarr/core/metadata/v3.py
# a rectilinear dimension's chunk spec: a bare int, a list of
# ints, or [value, count] run-length-encoded pairs, a new wire
# encoding not present in any released version of the format
RectilinearDimSpecJSON = int | list[int | list[int]]


class RectilinearChunkGridMetadata:
    def to_dict(self):
        serialized_dims = []
        for dim_spec in self.chunk_shapes:
            if isinstance(dim_spec, int):
                serialized_dims.append(dim_spec)
            else:
                # emit the RLE pairs into the stored document
                rle = compress_rle(dim_spec)
                if len(rle) < len(dim_spec):
                    serialized_dims.append(rle)
                else:
                    serialized_dims.append(list(dim_spec))
        return {"name": "rectilinear", "configuration": ...}
```

### Fix

```python
# gate the unreleased RLE encoding behind an explicit opt-in.
# until the format is deliberately released, emit the plain list
# form (the fallback that already exists here), so the stored
# bytes stay in an encoding that is safe to change later
def to_dict(self, *, emit_experimental_rle: bool = False):
    serialized_dims = []
    for dim_spec in self.chunk_shapes:
        if isinstance(dim_spec, int):
            serialized_dims.append(dim_spec)
        elif emit_experimental_rle:
            serialized_dims.append(compress_rle(dim_spec))
        else:
            serialized_dims.append(list(dim_spec))
    ...
```

The real move is a decision, not a refactor: treat a wire format as a one-way
door and spend care in proportion to how hard it is to undo. A format that
escapes into stored data is about as hard to undo as it gets, and the plain list
is already a valid, stable encoding, so there is no reason to emit the
unreleased RLE form by default.

A related split from another run: earthaccess's ideal fix (parsing raw JSON into
a typed model) changes a public return type in the middle of a deprecation
cycle, a one-way door, while several cheap fixes nearby (making `__repr__` pure,
for instance) are fully reversible. The right move was to separate them: plan
the one-way change deliberately, and land the two-way fixes immediately.

*Source: [src/zarr/core/metadata/v3.py#L180-L182][src13] @ 13279cac (external,
2026-07-10/11).*

---

## 10. Verify by running the breaking case, not by reasoning

*Python. Self-authored: covjson-msgspec.*

The type signature and the docstring both claim this function is correct.
Reading them, you would affirm it. Only constructing a legal-but-extreme input
and actually running it reveals that the claim is false.

### The claim

```python
def resolve(raw: str) -> Moment:
    # the docstring asserts correctness for out-of-range dates
    """Returns status='Unrepresentable' for dates outside the
    representable range."""
    ...
```

### Running the edge

The edge input pairs an extreme year with a malformed month; a twin input holds
the month fixed to isolate which part is actually at fault:

```python
# a legal-to-parse but boundary input: year 0000 with month 13
resolve("0000-13-01").status
# 'Unrepresentable'

# a twin that varies only the year, holding the malformed month
# fixed
resolve("2020-13-01").status
# 'Malformed'
```

The first result is wrong. Month 13 is malformed whatever the year, so both
inputs should report `Malformed`; the year-0000 case is mislabeled
`Unrepresentable`, and the twin proves the year was never the problem. The
mislabel matters because a downstream validation pass keys off the label: an
`Unrepresentable` verdict is handled differently from a `Malformed` one, so the
wrong label defeats the check. That downstream trace is what promotes this from
a cosmetic naming nit to a real finding.

The move is the discipline, not any particular code change: name the assumption
the design rests on, construct the *legal* input that violates it, and run it. A
verdict of "that case is bounded" or "negligible" is unearned until that input
has actually been run. In a companion run, exactly such a "bounded, negligible"
park on a clamped coordinate turned out, once the maximizing input was finally
run, to reject ordinary equatorial reads.

*Source: covjson-msgspec `feat/temporal`, 2026-07-07 (self-authored); the
unearned-park example from titiler-covjson #41, 2026-07-13 (self-authored).*

<!-- external-source links -->
[src1]: https://github.com/earthaccess-dev/earthaccess/blob/bbbced0b/earthaccess/auth.py#L111-L153
[src2]: https://github.com/developmentseed/titiler-cmr/blob/5101ef06/titiler/cmr/utils.py#L76
[src3]: https://github.com/developmentseed/titiler-cmr/blob/5101ef06/titiler/cmr/dependencies.py#L307
[src4]: https://github.com/earthaccess-dev/earthaccess/blob/bbbced0b/earthaccess/virtual/_types.py#L10-L19
[src5]: https://github.com/zarr-developers/zarr-python/blob/13279cac/src/zarr/core/metadata/v3.py#L96
[src6]: https://github.com/earthaccess-dev/earthaccess/blob/bbbced0b/earthaccess/results.py#L323
[src7]: https://github.com/earthaccess-dev/earthaccess/blob/bbbced0b/earthaccess/results.py#L358-L369
[src8]: https://github.com/developmentseed/titiler-cmr/blob/5101ef06/titiler/cmr/credentials.py#L61
[src9]: https://github.com/zarr-developers/zarr-python/blob/13279cac/src/zarr/core/metadata/v3.py#L612
[src10]: https://github.com/zarr-developers/zarr-python/blob/13279cac/src/zarr/core/group.py#L413
[src11]: https://github.com/developmentseed/titiler-cmr/blob/5101ef06/titiler/cmr/models.py#L181
[src12]: https://github.com/developmentseed/titiler-cmr/blob/5101ef06/titiler/cmr/models.py#L416
[src13]: https://github.com/zarr-developers/zarr-python/blob/13279cac/src/zarr/core/metadata/v3.py#L180-L182
