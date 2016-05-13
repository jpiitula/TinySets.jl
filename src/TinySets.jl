# http://docs.julialang.org/en/release-0.4/manual/documentation/

"""
    TinySets.TinyPart{N}, TinySets.TinyRelation{N}

Parts of and relations on a set of `N` elements up to `N == 8`.

The module is intended for conceptual exploration. There are more than
enough tiny things to be of interest, and they can be used to study
much bigger worlds: certain types of tiny relations correspond to
finite topological spaces.

Parts are considered **as parts of** and relations **as relations on**
the `N`-element set. The elements have standard names and nicknames.

* `Pt"1"` is {1} as a part of {1}, aka {a} as a part of {a})
* `Pt"100"` is {1} as a part of {1,2,3}, aka {a} as a part of {a,b,c}

# Contents

* Boolean lattice operations, inclusion predicate
* Composition and inversion of relations
* Diagonal correspondence of parts and relations
* Random parts and relations
* Iteration protocols

# Examples
```julia
julia> Pt"001" ∘ Rn"101 010 101"
Tiny 3-Part
  1 0 1

julia> collect(filter(r -> eye(r) ⊆ r == r', TinyRelation{3}))
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

import Base: start, done, next, eltype
import Base: hash, getindex, length
import Base: ∈
import Base: zero, one, eye, diag
import Base: ∩, ∪, ~
import Base: ×
import Base: ⊆

export TinyPart, TinyRelation
export @Pt_str, @Rn_str
export each, point
export diagr
export randp, randr
export ∘

include("Type.jl")
include("Each.jl")
include("Core.jl")

end