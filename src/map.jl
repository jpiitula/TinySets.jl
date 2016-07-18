"""
"""

immutable TinyMap
    rule :: UInt64
    dom :: TinySet
    cod :: TinySet
end

eltype(f::TinyMap) = Pair{Int,Int}
length(f::TinyMap) = length(dom(f))
start(f::TinyMap) = 0
done(f::TinyMap, state) = done(dom(f), state)
function next(f::TinyMap, state)
    input, state = next(dom(f), state)
    rule = ruleof(f)
    output = 1 + trailing_zeros(rule >> (8 * (input - 1)))
    (input => output), state
end

"""
    tinymap(T, m => n, ...)

maps points `m...` (giving the domain) to points `n...` in codomain
`T` which must be a `TinySet` that contains all of `n...`. Points are
given as integers from `1` to `8`.
"""

function tinymap(cod::TinySet, points::Pair{Int,Int}...)
    domain = zero(UInt8)
    codomain = reinterpret(UInt8, cod)
    for (m,n) in points
        1 <= m <= 8 || error("invalid point")
        1 <= n <= 8 || error("invalid point")
        domain & (0x01 << (m - 1)) == 0 || error("double point")
        domain |= 0x01 << (m - 1)
        codomain & (0x01 << (n - 1)) > 0 || error("out of type")
    end

    dom = reinterpret(TinySet, domain)
    rule = zero(UInt64)
    for (m,n) in points
        rule |= UInt64(0x01 << (n - 1)) << (8 * (m - 1))
    end
    TinyMap(rule, dom, cod)
end

"""
    dom(f::TinyMap)::TinySet
"""

dom(f::TinyMap) = f.dom

"""
    cod(f::TinyMap)::TinySet
"""

cod(f::TinyMap) = f.cod

"""
    ruleof(dom::TinySet)::UInt64

A canonical rule that maps each point in `dom` to itself in the
ultimate codomain. This is an implementation detail. Because used for
set operations on parts. And id.
"""

function ruleof(dom::TinySet)
    domain = UInt64(reinterpret(UInt8, dom))
    rule = zero(UInt64)
    for (s,t) in zip(0:7, 0:8:56)
        rule |= (domain & (0x01 << s)) << t
    end
    rule
end

"""
    ruleof(f::TinyMap)::UInt64
"""

ruleof(f::TinyMap) = f.rule

==(f::TinyMap, g::TinyMap) = (dom(f) == dom(g) &&
                              cod(f) == cod(g) &&
                              ruleof(f) == ruleof(g))

"""
    id(dom::TinySet)::TinyMap

The identity map of `dom`.
"""

id(dom::TinySet) = TinyMap(ruleof(dom), dom, dom)

"""
    asmap(dom::TinySet)::TinyMap

The canonical way of `dom` to be a part of `can(8)`.
"""

asmap(dom::TinySet) = TinyMap(ruleof(dom), dom, can(8))

"""
    image(f::TinyMap)::TinySet

A canonical image of a tiny map. Used to implement set operations on
parts.
"""

image(f::TinyMap) = reinterpret(TinySet, image(f.rule))

function image(rule::UInt64)
    img = zero(UInt64)
    for t in 0:8:56
        img |= rule >> t
    end
    UInt8(img &= 0xff)
end

"""
    ismono(f::TinyMap)::Bool
"""

ismono(f::TinyMap) = length(image(f)) == length(dom(f))

"""
    isepi(f::TinyMap)::Bool
"""

isepi(f::TinyMap) = length(image(f)) == length(cod(f))

"""
    checkparts(f, g)

Make sure that `f` and `g` are monomaps with a common codomain.
Throws an error otherwise. This is an implementation detail.
"""

function checkparts(f::TinyMap, g::TinyMap)
    ismono(f) || error("not mono")
    ismono(g) || error("not mono")
    cod(f) == cod(g) || error("not same type")
end

"""
    (f ⊆ g) == issubset(f::TinyMap, g::TinyMap)

Only when `f` and `g` are monomaps with the same codomain.
"""

function issubset(f::TinyMap, g::TinyMap)
    checkparts(f, g)
    (ruleof(f) & ~ruleof(g)) == zero(UInt64)
end

⊆(f::TinyMap, g::TinyMap) = issubset(f, g)

"""
    f ∩ g == intersection(f::TinyMap, g::TinyMap) :: TinyMap
"""

function intersection(f::TinyMap, g::TinyMap)
    checkparts(f, g)
    res = image(f) ∩ image(g)
    TinyMap(ruleof(res), res, cod(f))
end

∩(f::TinyMap, g::TinyMap) = intersection(f, g)

"""
    f ∪ g == union(f::TinyMap, g::TinyMap) :: TinyMap
"""

function union(f::TinyMap, g::TinyMap)
    checkparts(f, g)
    res = image(f) ∪ image(g)
    TinyMap(ruleof(res), res, cod(f))
end

∪(f::TinyMap, g::TinyMap) = union(f, g)

"""
    top(f::TinyMap) :: TinyMap

A largest part of the codomain.
"""

top(f::TinyMap) = id(cod(f))

"""
    bot(f::TinyMap) :: TinyMap

A smallest part of the codomain.
"""

bot(f::TinyMap) = tinymap(cod(f))

"""
    (f ≅ g) == isequivalent(f::TinyMap, g::TinyMap) == (image(f) == image(g))
"""

function isequivalent(f::TinyMap, g::TinyMap)
    checkparts(f, g)
    image(f) == image(g)
end

≅(f::TinyMap, g::TinyMap) = isequivalent(f, g)

"""
    f - g == difference(f::TinyMap, g::TinyMap) :: TinyMap
"""

function difference(f::TinyMap, g::TinyMap)
    checkparts(f, g)
    res = image(f) - image(g)
    TinyMap(ruleof(res), res, cod(f))
end

(-)(f::TinyMap, g::TinyMap) = difference(f, g)

"""
    ~f == complement(f::TinyMap) :: TinyMap

A complement of the part with respect to its codomain.
"""

# should not this be top(f) - f because of course it should

function complement(f::TinyMap)
    ismono(f) || error("not mono")
    res = cod(f) - image(f)
    TinyMap(ruleof(res), res, cod(f))
end

~(f::TinyMap) = complement(f)
