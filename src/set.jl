"""
    TinySet

A tiny set is a part of (a monomap to) an underlying 8-point set whose
points are named with the integers from `1` to `8`. There are 256 tiny
sets.

* `collect(tinyset(3,1,4)) == [1,3,4]`

Tiny sets participate in different systems. They support Boolean
lattice operations as parts in the underlying category. With respect
to the composition of tiny maps and relations, they correspond to
identity maps in the more structured categories.

"""

bitstype 8 TinySet

eltype(dom::TinySet) = Int

"""
    length(dom::TinySet)

The number of points in the tiny set.
"""

length(dom::TinySet) = count_ones(reinterpret(UInt8, dom))

start(data::TinySet) = 0
done(data::TinySet, state) = (reinterpret(UInt8, data) >> state) == 0x00
function next(data::TinySet, state)
    state += 1 + trailing_zeros(reinterpret(UInt8, data) >> state)
    state, state
end

function ∈(k::Int, a::TinySet)
    reinterpret(UInt8, a) & (one(UInt8) << (k - 1)) > zero(UInt8)
end

"""
    can(n) :: TinySet

A "canonical" part of `can(8)` for 0, 1, 2, 3, ..., 8 points.
"""

can(n) = reinterpret(TinySet, 0xff >> (8 - n))

"""
    tinyset(n::Int...) :: TinySet

The set of points `n`, all between `1` and `8`, considered canonically
as a part of `can(8)`.
"""

function tinyset(points...)
    s = 0x00
    for n in points
        1 <= n <= 8 || error("invalid point")
        s |= 0x01 << (n - 1)
    end
    reinterpret(TinySet, s)
end

# First implement set operations on tiny *sets* which are parts of 8
# in a canonical way. Then use these to implement set operations on
# tiny *maps* in terms of their canonical *images*.

"""
    top(f::TinySet) == can(8) :: TinySet

A largest part of `can(8)` as a TinySet.
"""

top(f::TinySet) = can(8)

"""
    bot(f::TinySet) == tinyset() :: TinySet

A smallest part of `can(8)` as a TinySet.
"""

bot(f::TinySet) = tinyset()

# Equivalence of tiny sets as parts of can(8), like top and bot for
# TinySet, lets them serve as short-hand parts. Main parts are maps.

"""
    (f ≅ g) == isequivalent(f::TinySet, g::TinySet) == (f == g)
"""

≅(f::TinySet, g::TinySet) = f == g

"""
    (f ⊆ g) == issubset(f::TinySet, g::TinySet)
"""

function issubset(f::TinySet, g::TinySet)
    (reinterpret(UInt8, f) & ~reinterpret(UInt8, g)) == zero(UInt8)
end

⊆(f::TinySet, g::TinySet) = issubset(f, g)

"""
    f ∩ g == intersection(f::TinySet, g::TinySet) :: TinySet
"""

function intersection(f::TinySet, g::TinySet)
    a = reinterpret(UInt8, f)
    b = reinterpret(UInt8, g)
    reinterpret(TinySet, a & b)
end

∩(f::TinySet, g::TinySet) = intersection(f, g)

"""
    f ∪ g == union(f::TinySet, g::TinySet) :: TinySet
"""

function union(f::TinySet, g::TinySet)
    a = reinterpret(UInt8, f)
    b = reinterpret(UInt8, g)
    reinterpret(TinySet, a | b)
end

∪(f::TinySet, g::TinySet) = union(f, g)

"""
    f - g == difference(f::TinySet, g::TinySet) :: TinySet
"""

function difference(f::TinySet, g::TinySet)
    a = reinterpret(UInt8, f)
    b = reinterpret(UInt8, g)
    reinterpret(TinySet, a & ~b)
end

(-)(f::TinySet, g::TinySet) = difference(f, g)

"""
    ~f == complement(f::TinySet) :: TinySet
"""

function complement(f::TinySet)
    a = reinterpret(UInt8, f)
    reinterpret(TinySet, ~a)
end

~(f::TinySet) = complement(f)

"""
    domto(set::TinySet, newdom) :: TinyMap
Makes a tiny isomap that pairs values (in `1:8`) from `newdom` with
the points of `set`. Checks that there are at least as many values in
`newdom` as in `set` and they are distinct from each other.
"""

function domto(set::TinySet, newdom)
    rule = zero(UInt64)
    dom = zero(UInt8)
    for (input,output) in zip(newdom,set)
        rule = setbit(rule, input, output)
        dom = setbit(dom, input)
    end
    count_ones(dom) == length(set) || error("mismatch")
    TinyMap(rule, reinterpret(TinySet, dom), set)
end

"""
    codto(set::TinySet, newcod) :: TinyMap

Makes a tiny isomap that pairs the points of `set` with values from
`newcod` (in `1:8`). Checks that there are at least as many values in
`newcod` as in `set` and they are distinct from each other.
"""

function codto(set::TinySet, newcod)
    rule = zero(UInt64)
    cod = zero(UInt8)
    for (input,output) in zip(set,newcod)
        rule = setbit(rule, input, output)
        cod = setbit(cod, output)
    end
    count_ones(cod) == length(set) || error("mismatch")
    TinyMap(rule, set, reinterpret(TinySet, cod))
end
