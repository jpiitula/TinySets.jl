# http://docs.julialang.org/en/release-0.4/manual/documentation/

"""
    TinySets: TinySet, TinyMap, TinyRelation

/Tiny sets/ are the 256 parts of an underlying 8-element set. /Tiny
maps/ and /tiny relations/ are functions and relations between tiny
sets.

The module is intended for conceptual exploration. There are easily
enough tiny things to be of interest, and they can be used to study
much bigger worlds. Certain types of tiny relations correspond to
finite topological spaces.

* `tinyset(1)` and `tinyset(3)` are one-point sets.
* `tinyset(3,1,4)` is a three-point set.
* `tinymap(tinyset(3,1,4), 1 => 1)` is a point of `tinyset(3,1,4)`.
* `graph(id(tinyset(3,1,4)))` is an identity relation

# Contents

* Boolean lattice operations, inclusion predicate
* Composition and inversion of relations
* Diagonal correspondence of parts and relations
* Random parts and relations
* Iteration protocols

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

import Base: hash, getindex
import Base: zero, one, eye, diag

export ExPart, ExRelation
export @Pt_str, @Rn_str
export each, point
export diagr
export randp, randr

# new start - keep some of the old imports and exports above
import Base: start, done, next, eltype, length
import Base: rand
import Base: ctranspose # for f' and r'
import Base: ==, (-)
import Base: ∩, ∪, ~ # UNION
import Base: ⊆
import Base: ∈ # ELEMENT OF
import Base: × # MULTIPLICATION SIGN
export ∘ # RING OPERATOR
export ≅ # APPROXIMATELY EQUAL TO; Julia reserves ≡ for its ===
export randpart, randpartition, randrelation
export randmap, randmono, randepi, randiso
export injections, surjections # combinatorical generation in general
export eachmap, eachmono, eachepi, eachrelation
export pairfrom, pairto
export TinySet, tinyset, id
export TinyMap, tinymap, dom, cod, graph
export TinyRelation, tinyrelation, composition, opposite
export image, ismono, isepi, isiso
export top, bot

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
# new start

# old design, going away
include("carpet/Type.jl")
include("carpet/Each.jl")
include("carpet/Core.jl")

end
