"""
    rand(TinySet)::TinySet

One of the 256 possible tiny sets at random.
"""

rand(::Type{TinySet}) = reinterpret(TinySet, rand(UInt8))

"""
    randpart(cod::TinySet)::TinyMap

A random canonical part of the given codomain (a tiny monomap with
that codomain and an identity rule as a representative of an
equivalence class).
"""

function randpart(cod::TinySet)
    res = reinterpret(TinySet, rand(UInt8) & reinterpret(UInt8, cod))
    TinyMap(ruleof(res), res, cod)
end

"""
    randpartition(dom::TinySet)

A random canonical partition of the given domain (an epimap with that
domain and what rule exactly as a representative of an equivalence
class).
"""

function randpartition(dom::TinySet)
    # todo
end
