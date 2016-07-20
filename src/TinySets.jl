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

(A tiny relation can in principle be identified in the same way by its
domain, codomain, and its pairs of points of the underlying set. At
the time of writing this is not implemented. Todo? Todo!)

# Contents

* Boolean lattice operations, inclusion predicate
* Composition and inversion of relations
* Diagonal correspondence of parts and relations
* Random parts and relations
* Iteration protocols

# Examples (obsolete)
```julia
julia> Pt"001" ∘ Rn"101 010 101"
Tiny 3-Part
  1 0 1

julia> collect(filter(r -> eye(r) ⊆ r == r', ExRelation{3}))
8-element Array{Any,1}:
 Rn"100 010 001"
 Rn"100 011 011"
 Rn"101 010 101"
 Rn"101 011 111"
 Rn"110 110 001"
 Rn"110 111 011"
 Rn"111 110 101"
 Rn"111 111 111"

julia> collect(each(Symbol, Rn"101 010 101"))
5-element Array{Tuple{Symbol,Symbol},1}:
 (:a,:a)
 (:a,:c)
 (:b,:b)
 (:c,:a)
 (:c,:c)

```
"""
module TinySets

import Base: hash, getindex
import Base: ∈
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
import Base: ∩, ∪, ~
import Base: ⊆
import Base: × # MULTIPLICATION SIGN
export ∘ # RING OPERATOR
export ≅ # APPROXIMATELY EQUAL TO; Julia reserves ≡ for its ===
export randpart, randpartition, randrelation
export randmap, randmono, randepi, randiso
export domto, codto
export TinySet, can, tinyset, asmap, id
export TinyMap, tinymap, dom, cod, graph
export TinyRelation, composition, opposite
export image, ismono, isepi, isiso
export top, bot

function setbit(rule::UInt64, r::Int, k::Int)
    rule | one(UInt64) << (8 * (r - 1) + (k - 1))
end

function setbit(set::UInt8, k::Int)
    set | one(UInt8) << (k - 1)
end

include("set.jl")
include("map.jl")
include("relation.jl")
include("bell.jl")
include("rand.jl")
# new start

# old design, going away
include("carpet/Type.jl")
include("carpet/Each.jl")
include("carpet/Core.jl")

end
