using TinySets
using Base.Test

# write your own tests here
@test 1 == 1

info("=== new start tests ===")
@test 1 == 1
@test length(can(0)) == 0
@test length(can(3)) == 3
@test can(0) == tinyset()
@test can(3) == tinyset(1,2,3)
@test dom(tinymap(can(3))) == tinyset()
@test cod(tinymap(can(3))) == can(3)
@test dom(tinymap(can(3), 1 => 2)) == can(1)
@test cod(tinymap(can(3), 1 => 2)) == can(3)
# @test ruleof(tinymap(can(3))) == zero(UInt64) - export ruleof?
@test tinymap(can(3)) == tinymap(can(3))
@test tinymap(can(3)) != tinymap(can(3), 1 => 2)
@test id(can(3)) == tinymap(can(3), 1 => 1, 2 => 2, 3 => 3)
@test image(id(can(3))) == can(3)
@test image(id(tinyset(3,1,4))) == tinyset(3,1,4)
@test ismono(id(tinyset(3,1,4)))
@test ismono(tinymap(can(3), 1 => 2, 2 => 1))
@test !ismono(tinymap(can(3), 1 => 2, 2 => 2))
@test isepi(id(tinyset(3,1,4)))
@test isepi(tinymap(can(3), 1 => 2, 2 => 1, 3 => 3))
@test !isepi(tinymap(can(3), 1 => 2, 2 => 1, 3 => 2))
@test can(2) ∩ can(3) == can(2)
@test can(2) ∪ can(3) == can(3)
@test asmap(tinyset(3,1,4)) == tinymap(can(8), 3 => 3, 1 => 1, 4 => 4)
@test asmap(can(8)) == id(can(8))
@test image(asmap(tinyset(3,1,4)) ∩ asmap(tinyset(4,1))) == tinyset(4,1)
@test image(asmap(tinyset(3,1,4)) ∩ asmap(tinyset(4,5))) == tinyset(4)
@test image(asmap(tinyset(3,1,4)) ∪ asmap(tinyset(4,5))) == tinyset(5,4,3,1)
@test image(asmap(tinyset(3,1,4)) ∩ asmap(tinyset(5))) == tinyset()
@test image(asmap(tinyset(3,1,4)) ∪ asmap(tinyset(5))) == tinyset(5,4,3,1)
@test ismono(asmap(tinyset(3,1,4)) ∩ asmap(tinyset(4,1)))
@test ismono(asmap(tinyset(3,1,4)) ∩ asmap(tinyset(4,5)))
@test ismono(asmap(tinyset(3,1,4)) ∪ asmap(tinyset(4,1)))
@test ismono(asmap(tinyset(3,1,4)) ∪ asmap(tinyset(4,5)))
@test ~can(8) == can(0)
@test ~can(0) == can(8)
@test ~asmap(can(8)) == asmap(can(0))
@test ~asmap(can(0)) == asmap(can(8))
info("=== new start tests done ===")

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

info("=== New lattice algebra tests")
let cod = rand(TinySet)
    latticealgebra(tinyset(), tinyset(), tinyset())
    latticealgebra(rand(TinySet), rand(TinySet), rand(TinySet))
    latticealgebra(randpart(cod), randpart(cod), randpart(cod))
end
info("=== New lattice algebra tests done")

function latticeorder(x, y, z)
    @test bot(x) ⊆ x ⊆ top(x)
    @test x ∩ z ⊆ x
    @test x ⊆ x ∪ z
end

info("=== New lattice order tests not runnable yet")

# need issubset and even then there is a mix of maps and sets when
# testing on sets - shorthand is always trouble

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
    @test r^0 == eye(r)
    @test r^1 == r
    @test r^2 == r ∘ r
    @test r^3 == r ∘ r ∘ r
end

function diagonal_tests{N}(A::TinyPart{N}, R::TinyRelation{N})
    @test diagr(zero(A)) == zero(R)
    @test diagr(one(A)) == eye(A) == eye(R)
    @test diag(zero(R)) == zero(A)
    @test diag(one(R)) == one(A)
    @test diag(diagr(A)) == A
    @test diagr(diag(R)) ⊆ R
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

function product_tests(A, B)
    @test A × B == reduce(∪, zero(A × B),
                          map(k -> k × B,
                              each(Int, A)))
    @test A × B == reduce(∪, zero(A × B),
                          map(k -> A × k,
                              each(Int, B)))
    @test A × B == (B × A)'
    @test zero(A) × B == zero(A × B) == A × zero(B)
    @test one(A) × one(B) == one(A × B)
    @test B == zero(B) || A == (A × B) ∘ one(B)
    @test A == zero(A) || B == one(A) ∘ (A × B)
end

function each_tests{N}(A::TinyPart{N}, R::TinyRelation{N})
    @test length(zero(A)) == length(Set(each(Int, zero(A)))) == 0
    @test length(zero(R)) == length(Set(each(Int, zero(R)))) == 0
    @test length(one(A)) == length(Set(each(Int, one(A)))) == N
    @test length(one(R)) == length(Set(each(Int, one(R)))) == N^2
    @test length(TinyPart{N}) == 2^N
    @test length(TinyRelation{N}) == 2^(N^2)
    @test length(A) == length(Set(each(Int, A)))
    @test length(R) == length(Set(each(Int, R)))
    @test length(A) == length(Set(each(Char, A)))
    @test length(R) == length(Set(each(Char, R)))
    @test length(A) == length(Set(each(Symbol, A)))
    @test length(R) == length(Set(each(Symbol, R)))
end

function point_tests(A, R)
    @test A == reduce(∪, zero(A),
                      map(k -> point(A, k),
                          each(Int, A)))
    @test R == reduce(∪, zero(R),
                      map(p -> point(R, p...),
                          each(Int, R)))

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

    info("Diagonal tests on a random 3-part and 3-relation")
    diagonal_tests(a, r)

    info("Indexing tests on a random 3-relation")
    indexing_tests(r)

    info("Opposite tests on a random 3-relation and 3-part")
    opposite_tests(r, a)

    info("Product tests on random 3-parts")
    product_tests(a, b)

    info("Each-tests on a random 3-part and 3-relation")
    each_tests(a, r)

    info("Point-tests on a random 3-part and 3-relation")
    point_tests(a, r)
end
