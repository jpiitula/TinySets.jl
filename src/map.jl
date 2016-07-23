"""
    TinyMap

A tiny map is a function from a tiny set to a tiny set. A tiny map can
be specified by giving its codomain and the value at each point of the
domain. There are `n^m` functions from an `m`-point set to an
`n`-point set.

* `collect(tinymap(tinyset(3,1,4), 2 => 3, 5 => 4)) == [2=>3,5=>4]`

Maps with compatible types can be composed. Monomaps support Boolean
algebras as parts of a shared codomain.

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

isiso(f::TinyMap) = ismono(f) && isepi(f)

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

"""
    domto(f::TinyMap, newdom)
Composes `f` with a tiny isomap that pairs values from `newdom` with
the points of `dom(f)`. Checks that there are at least as many values
in `newdom` as in `dom(f)` and they are distinct from each other.
"""

function domto(f::TinyMap, newdom)
    rule = zero(UInt64)
    from = zero(UInt8)
    for (input,old) in zip(newdom,f)
        _,output = old
        rule = setbit(rule, input, output)
        from = setbit(from, input)
    end
    count_ones(from) == length(dom(f)) || error("mismatch")
    TinyMap(rule, reinterpret(TinySet, from), cod(f))
end

"""
    codto(f::TinyMap, newcod)
Composes with `f` a tiny isomap that pairs the points of `cod(f)` with
values from `newcod`. Checks that there are at least as many values in
`newcod` as in `cod(f)` and they are distinct from each other.
"""

function codto(f::TinyMap, newcod)
    rule = zero(UInt64)
    to = zero(UInt8)
    pairing = Dict(zip(cod(f), newcod))
    for (input,old) in f
        rule = setbit(rule, input, pairing[old])
    end
    for (old,new) in pairing
        to = setbit(to, new)
    end
    count_ones(to) == length(cod(f)) || error("mismatch")
    TinyMap(rule, dom(f), reinterpret(TinySet, to))
end
