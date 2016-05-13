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
