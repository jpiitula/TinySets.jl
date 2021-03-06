# Copyright 2016 Jussi Piitulainen; free under GPLv3+, no warranty

# http://docs.julialang.org/en/release-0.4/manual/documentation/

"""
    TinySets: TinySet, TinyMap, TinyRelation

/Tiny sets/ are the 256 parts of an underlying 8-element set. /Tiny
maps/ and /tiny relations/ are the 28,501,125 functions and
19,653,639,560,140,008,575 binary relations that have a specific tiny
set as their domain and a specific tiny set as their codomain, in
different categories.

* `tinyset(1)` and `tinyset(3)` are one-point sets.
* `tinyset(3,1,4)` is a three-point set.
* `tinymap(tinyset(3,1,4), 1 => 1)` is a point of `tinyset(3,1,4)`.
* `graph(id(tinyset(3,1,4)))` is an identity relation

# Examples
```julia> map(collect, eachepi(tinyset(2,5,8), tinyset(3,1)))
6-element Array{Any,1}:
 [2=>1,5=>1,8=>3]
 [2=>3,5=>3,8=>1]
 [2=>1,5=>3,8=>1]
 [2=>3,5=>1,8=>3]
 [2=>1,5=>3,8=>3]
 [2=>3,5=>1,8=>1]

```
"""
module TinySets

import Base: hash # to hash

import Base: start, done, next, eltype, length
import Base: rand
import Base: ctranspose # for f' and r'
import Base: ==, (-), ^
import Base: ∩, ∪, ~ # INTERSECTION, UNION, \cap, \cup
import Base: ⊆ # SUBSET OF OR EQUAL TO, \subseteq
import Base: ∈ # ELEMENT OF, \in
import Base: × # MULTIPLICATION SIGN

import Iterators: product # hm, TinySets.product a method of that?

export ∘ # RING OPERATOR
export ≅ # APPROXIMATELY EQUAL TO; Julia reserves ≡ for its ===
export randpart, randpartition
export randrelation, randequivalence
export randmap, randmono, randepi, randiso
export injections, surjections # combinatorical generation in general
export eachmap, eachmono, eachpart, eachepi, eachpartition
export eachrelation, eachequivalence
export pairfrom, pairto
export TinySet, tinyset, id
export TinyMap, tinymap, dom, cod, graph, inverse
export TinyRelation, tinyrelation, composition, opposite
export image, preimage, ismono, isepi, isiso
export top, bot

# bring tinyrow (from relation.jl) to these other auxiliaries

function setbit(rule::UInt64, r::Int, k::Int)
    rule | (one(UInt64) << (8 * (r - 1) + (k - 1)))
end

function testbit(rule::UInt64, r::Int, k::Int)
    rule & (one(UInt64) << (8 * (r - 1) + (k - 1))) > zero(UInt64)
end

function setbit(set::UInt8, k::Int)
    set | (one(UInt8) << (k - 1))
end

function testbit(set::UInt8, k::Int)
    set & (one(UInt8) << (k - 1)) > zero(UInt8)
end

include("set.jl")
include("map.jl")
include("relation.jl")
include("bell.jl")
include("rand.jl")
include("iter.jl") # combinatorical generation in general
include("each.jl")

end
