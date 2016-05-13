using TinySets
using Base.Test

# write your own tests here
@test 1 == 1

function lattice_tests(x, y, z)
    @test x == x
    @test zero(x) ⊆ x ⊆ one(x)
    @test x ∩ x == x 
    @test x ∪ x == x
    @test x ∩ z == z ∩ x
    @test x ∪ z == z ∪ x
    @test x ∩ (y ∩ z) == (x ∩ y) ∩ z
    @test x ∪ (y ∪ z) == (x ∪ y) ∪ z
    @test x ∩ (y ∪ z) == (x ∩ y) ∪ (x ∩ z)
    @test x ∪ (y ∩ z) == (x ∪ y) ∩ (x ∪ z)
    @test x ∩ (x ∪ z) == x
    @test x ∪ (x ∩ z) == x
    @test x ∩ one(x) == x
    @test x ∩ zero(x) == zero(x)
    @test x ∪ one(x) == one(x)
    @test x ∪ zero(x) == x
    @test x - zero(x) == x
    @test zero(x) - x == zero(x)
    @test x - x == zero(x)
    @test x - one(x) == zero(x)
    @test one(x) - x == ~x
    @test x - z == x ∩ ~z
    @test ~~x == x
    @test ~(x ∩ z) == ~x ∪ ~z
    @test ~(x ∪ z) == ~x ∩ ~z
    @test x ∩ ~x == zero(x)
    @test x ∪ ~x == one(x)
    @test x ∩ z ⊆ x
    @test x ⊆ x ∪ z
end

function composition_tests(r, s, t)
    @test eye(r) ∘ r == r == r ∘ eye(r)
    @test r ∘ (s ∘ t) == (r ∘ s) ∘ t
    @test (r ∘ s)' == s' ∘ r'
end

function indexing_tests{N}(r::TinyRelation{N})
    for j in 1:N, k in 1:N
        @test ((j,k) ∈ r) == (r[j,k] == 1)
        @test ((j,k) ∈ r) == (k ∈ r[j,:]) == (r[j,:][k] == 1)
        @test ((j,k) ∈ r) == (j ∈ r[:,k]) == (r[:,k][j] == 1)
    end
end

function opposite_tests{N}(r::TinyRelation{N}, a::TinyPart{N})
    @test r == r''
    @test a ∘ r == r' ∘ a
    for j in 1:N, k in 1:N
        @test ((j,k) ∈ r) == ((k,j) ∈ r')
    end
    for k in 1:N
        @test r[k,:] == r'[:,k]
    end
end

let
    a, b, c = randp(3), randp(3), randp(3)
    r, s, t = randr(3), randr(3), randr(3)

    info("Lattice tests on random 3-parts")
    lattice_tests(a, b, c)

    info("Lattice tests on random 3-relations")
    lattice_tests(r, s, t)

    info("Composition tests on random 3-relations")
    composition_tests(r, s, t)

    info("Indexing tests on a random 3-relation")
    indexing_tests(r)

    info("Opposite test on a random 3-relation and 3-part")
    opposite_tests(r, a)
end
