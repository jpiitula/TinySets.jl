"""
    TinyRelation

A tiny relation is a part of a product and a map between tiny sets in
a different category. It can be specified by giving its domain and
codomain and points.

Tiny relations with the same domain and domain support underlying
Boolean algebras. As maps they are composable. There is always an
opposite relation.

"""

immutable TinyRelation
    rule::UInt64
    dom::TinySet
    cod::TinySet
end

==(a::TinyRelation, b::TinyRelation) = (a.rule == b.rule &&
                                        a.dom == b.dom &&
                                        a.cod == b.cod)

ruleof(a::TinyRelation) = a.rule

dom(a::TinyRelation) = a.dom
cod(a::TinyRelation) = a.cod

function tinyrelation(dom::TinySet, cod::TinySet, points::Pair{Int,Int}...)
    tinyrelation(dom, cod, points)
end

# could *also* allow Tuple{Int,Int}... but not *instead* and it would
# need tests or not done

function tinyrelation(dom::TinySet, cod::TinySet, points)
    rule = zero(UInt64)
    for (input,output) in points
        input ∈ dom || error("input not in domain")
        output ∈ cod || error("input not in codomain")
        rule = setbit(rule, input, output)
    end
    TinyRelation(rule, dom, cod)
end

function ∈(jk::Tuple{Int,Int}, r::TinyRelation)
    j, k = jk
    j ∈ dom(r) || error("input not in domain")
    k ∈ cod(r) || error("output not in codomain")
    testbit(ruleof(r), j, k)
end

graph(f::TinyMap) = TinyRelation(ruleof(f), dom(f), cod(f))

"Aux to iterate TinyRelation using TinySet iterator"
function tinyrow(a::TinyRelation, r::Int)
     tinyrow(ruleof(a), r)
end

tinyrow(f::TinyMap, r::Int) = tinyrow(ruleof(f), r)

function tinyrow(rule::UInt64, r::Int)
     row = (rule >> (8 * (r - 1))) & 0xff
     reinterpret(TinySet, UInt8(row))
end

# A relation is a set of pairs, so iteration order does not matter, so
# it can as well be "row by row" where a "row" means the values that
# correspond to a domain element. There probably will not be any other
# iterator, but there might be a nicer way to write an iterator. And
# the order of the pairs does not matter: should a nicer iterator use
# a different order, do so.

length(a::TinyRelation) = count_ones(ruleof(a))
eltype(a::TinyRelation) = Tuple{Int,Int}
start(a::TinyRelation) = (tinyrow(a, 1), 1, 0)
function done(a::TinyRelation, state)
    set, r, k = state
    done(set, k) && ruleof(a) >> (8 * r) == zero(UInt64)
end
function next(a::TinyRelation, state)
    set, r, k = state
    if done(set, k)
        next(a, (tinyrow(a, r + 1), r + 1, 0))
    else
        k, _ = next(set, k)
        (r, k), (set, r, k)
    end
end

function product(dom::TinySet, cod::TinySet)
    rule, outs = zero(UInt64), UInt64(reinterpret(UInt8, cod))
    for input in dom
        rule |= outs << (8 * (input - 1))
    end
    TinyRelation(rule, dom, cod)
end

×(a::TinySet, b::TinySet) = product(a, b)

top(a::TinyRelation) = dom(a) × cod(a)
bot(a::TinyRelation) = TinyRelation(zero(UInt64), dom(a), cod(a))

"Strictly type. Tiny relations are always parts."

function checkparts(a::TinyRelation, b::TinyRelation)
    dom(a) == dom(b) || error("not of type")
    cod(a) == cod(b) || error("not of type")
end

function is_included_in(a::TinyRelation, b::TinyRelation)
    checkparts(a, b)
    (ruleof(a) & ~ruleof(b)) == zero(UInt64)
end

⊆(a::TinyRelation, b::TinyRelation) = is_included_in(a, b)

function intersection(a::TinyRelation, b::TinyRelation)
    checkparts(a, b)
    TinyRelation(ruleof(a) & ruleof(b), dom(a), cod(a))
end

function isequivalent(a::TinyRelation, b::TinyRelation)
    checkparts(a, b)
    a == b
end

≅(a::TinyRelation, b::TinyRelation) = isequivalent(a, b)

∩(a::TinyRelation, b::TinyRelation) = intersection(a, b)

function union(a::TinyRelation, b::TinyRelation)
    checkparts(a, b)
    TinyRelation(ruleof(a) | ruleof(b), dom(a), cod(a))
end

∪(a::TinyRelation, b::TinyRelation) = union(a, b)

function difference(a::TinyRelation, b::TinyRelation)
    checkparts(a, b)
    TinyRelation(ruleof(a) & ~ruleof(b), dom(a), cod(a))
end

(-)(f::TinyRelation, g::TinyRelation) = difference(f, g)

complement(f::TinyRelation) = top(f) - f
~(f::TinyRelation) = complement(f)

"""
    (g ∘ f) == composition(g::TinyMap, f::TinyMap) :: TinyMap

    (s ∘ r) == composition(s::TinyRelation, r::TinyRelation) :: TinyRelation
"""

function composition{T<:Union{TinyMap,TinyRelation}}(g::T, f::T)
    dom(g) == cod(f) || error("not of type")
    rule = zero(UInt64)
    for (input,common) in f
        output = UInt64(reinterpret(UInt8, tinyrow(g, common)))
        rule |= output << (8 * (input - 1))
    end
    T(rule, dom(f), cod(g))
end

∘(g::TinyMap, f::TinyMap) = composition(g, f)
∘(s::TinyRelation, r::TinyRelation) = composition(s, r)

function inverse(f::TinyMap)
    isiso(f) || error("not invertible")
    TinyMap(ruleof(opposite(graph(f))), cod(f), dom(f))
end

function opposite(r::TinyRelation)
    rule = zero(UInt64)
    for (input,output) in r
        rule = setbit(rule, output, input)
    end
    TinyRelation(rule, cod(r), dom(r))
end

ctranspose(f::TinyMap) = inverse(f)
ctranspose(r::TinyRelation) = opposite(r)

function ^(f::TinyRelation, n::Int)
    dom(f) == cod(f) || error("not on")
    n >= 0 || error("not a number")
    if n == 0
        graph(id(dom(f)))
    else
        f ∘ f^(n - 1) # don't *do* large n
    end
end
