using TinySets
using Base.Test

function latticealgebra(x, y, z)
    @test x ≅ x
    @test x ∩ x ≅ x 
    @test x ∪ x ≅ x
    @test x ∩ z ≅ z ∩ x
    @test x ∪ z ≅ z ∪ x
    @test x ∩ (y ∩ z) ≅ (x ∩ y) ∩ z
    @test x ∪ (y ∪ z) ≅ (x ∪ y) ∪ z
    @test x ∩ (y ∪ z) ≅ (x ∩ y) ∪ (x ∩ z)
    @test x ∪ (y ∩ z) ≅ (x ∪ y) ∩ (x ∪ z)
    @test x ∩ (x ∪ z) ≅ x
    @test x ∪ (x ∩ z) ≅ x
    @test x ∩ top(x) ≅ x
    @test x ∩ bot(x) ≅ bot(x)
    @test x ∪ top(x) ≅ top(x)
    @test x ∪ bot(x) ≅ x
    @test x - bot(x) ≅ x
    @test bot(x) - x ≅ bot(x)
    @test x - x ≅ bot(x)
    @test x - top(x) ≅ bot(x)
    @test top(x) - x ≅ ~x
    @test x - z ≅ x ∩ ~z
    @test ~~x ≅ x
    @test ~(x ∩ z) ≅ ~x ∪ ~z
    @test ~(x ∪ z) ≅ ~x ∩ ~z
    @test x ∩ ~x ≅ bot(x)
    @test x ∪ ~x ≅ top(x)
end

function latticeorder(x, y, z)
    @test bot(x) ⊆ x ⊆ top(x)
    @test x ∩ z ⊆ x
    @test x ⊆ x ∪ z
end

info("=== New lattice algebra tests")

let empty = tinyset()
    latticealgebra(empty, empty, empty)
    latticeorder(empty, empty, empty)
end

let
    s = rand(TinySet)
    t = rand(TinySet)
    u = rand(TinySet)
    latticealgebra(s, t, u)
    latticeorder(s, t, u)
end

let cod = rand(TinySet)
    i = randpart(cod)
    j = randpart(cod)
    k = randpart(cod)
    latticealgebra(i, j, k)
    latticeorder(i, j, k)
end

let dom = rand(TinySet) ; cod = rand(TinySet)
    r = randrelation(dom, cod)
    s = randrelation(dom, cod)
    t = randrelation(dom, cod)
    latticealgebra(r, s, t)
    latticeorder(r, s, t)
end

info("=== New lattice algebra tests done")
