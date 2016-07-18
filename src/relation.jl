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

"Aux to iterate TinyRelation using TinySet iterator"
function tinyrow(a::TinyRelation, r::Int)
     row = (ruleof(a) >> (8 * (r - 1))) & 0xff
     reinterpret(TinySet, UInt8(row))
end

# A relation is a set of pairs, so iteration order does not matter, so
# it can as well be "row by row" where a "row" means the values that
# correspond to a domain element. There probably will not be any other
# iterator, but there might be a nicer way to write an iterator. And
# the order of the pairs does not matter: should a nicer iterator use
# a different order, do so.

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

function issubset(a::TinyRelation, b::TinyRelation)
    checkparts(a, b)
    (ruleof(a) & ~ruleof(b)) == zero(UInt64)
end

⊆(a::TinyRelation, b::TinyRelation) = issubset(a, b)

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
