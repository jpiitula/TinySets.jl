using TinySets
using Base.Test

include("set.jl")

info("=== new start tests ===")
@test dom(tinymap(tinyset(1:3))) == tinyset()
@test cod(tinymap(tinyset(1:3))) == tinyset(1:3)
@test dom(tinymap(tinyset(1:3), 1 => 2)) == tinyset(1:1)
@test cod(tinymap(tinyset(1:3), 1 => 2)) == tinyset(1:3)
@test tinymap(tinyset(1:3)) == tinymap(tinyset(1:3))
@test tinymap(tinyset(1:3)) != tinymap(tinyset(1:3), 1 => 2)
@test id(tinyset(1:3)) == tinymap(tinyset(1:3), 1 => 1, 2 => 2, 3 => 3)
@test isempty(tinymap(tinyset(1:5)))
@test length(tinymap(tinyset(1:5))) == 0
@test eltype(tinymap(tinyset(1:5))) == Pair{Int,Int}
@test collect(tinymap(tinyset(1:5))) == Pair{Int,Int}[]
@test !isempty(tinymap(tinyset(1:5), 3 => 1, 1 => 3, 4 => 4))
@test length(tinymap(tinyset(1:5), 3 => 1, 1 => 3, 4 => 4)) == 3
@test eltype(tinymap(tinyset(1:5), 3 => 1, 1 => 3, 4 => 4)) == Pair{Int,Int}
@test (collect(tinymap(tinyset(1:5), 3 => 1, 1 => 3, 4 => 4)) ==
       Pair[1 => 3, 3 => 1, 4 => 4])
@test image(id(tinyset(1:3))) == tinyset(1:3)
@test image(id(tinyset(3,1,4))) == tinyset(3,1,4)
@test ismono(id(tinyset(3,1,4)))
@test ismono(tinymap(tinyset(1:3), 1 => 2, 2 => 1))
@test !ismono(tinymap(tinyset(1:3), 1 => 2, 2 => 2))
@test isepi(id(tinyset(3,1,4)))
@test isepi(tinymap(tinyset(1:3), 1 => 2, 2 => 1, 3 => 3))
@test !isepi(tinymap(tinyset(1:3), 1 => 2, 2 => 1, 3 => 2))
@test tinyset(1:2) ∩ tinyset(1:3) == tinyset(1:2)
@test tinyset(1:2) ∪ tinyset(1:3) == tinyset(1:3)

let
    s314 = tinyset(3,1,4)
    s14 = tinyset(1,4)
    s45 = tinyset(4,5)
    topset = tinyset(1:8)
    botset = tinyset()
    m314 = tinymap(topset, 3 => 3, 1 => 1, 4 => 4)
    m14 = tinymap(topset, 4 => 4, 1 => 1)
    m45 = tinymap(topset, 4 => 4, 5 => 5)
    m5 = tinymap(topset, 5 => 5)
    @test tinymap(topset, id(s314)...) == m314
    @test tinymap(topset, id(topset)...) == id(topset)
    @test image(m314 ∩ m14) == s14
    @test image(m314 ∩ m45) == tinyset(4)
    @test image(m314 ∪ m45) == tinyset(5,4,3,1)
    @test image(m314 ∩ m5) == botset
    @test image(m314 ∪ m5) == tinyset(5,4,3,1)
    @test ismono(m314 ∩ m14)
    @test ismono(m314 ∪ m14)
    @test ismono(m314 ∩ m45)
    @test ismono(m314 ∪ m45)
    @test ~topset == botset
    @test ~botset == topset
    @test ~id(topset) == tinymap(topset)
    @test ~tinymap(topset) == id(topset)
end

@test ismono(randmono(tinyset(1:3), tinyset(1:4)))
@test isepi(randepi(tinyset(1:4), tinyset(1:3)))
@test isiso(randiso(tinyset(1:4), tinyset(1:4)))
info("=== new start tests done ===")

include("iter.jl")
include("each.jl")

info("=== iter ok ===")

let
    set = tinyset(3,1,4)

    f = domto(set, 1:8)
    @test dom(f) == tinyset(1,2,3)
    @test cod(f) == tinyset(3,1,4)
    @test isiso(f)

    g = codto(set, 1:8)
    @test dom(g) == tinyset(3,1,4)
    @test cod(g) == tinyset(1,2,3)
    @test isiso(g)
end

let
    f = tinymap(tinyset(3,1,4), 2 => 3, 7 => 4)

    g = domto(f, 1:8)
    @test dom(g) == tinyset(1,2)
    @test cod(g) == tinyset(3,1,4)
    @test ismono(g)
    @test g == tinymap(cod(f), 1 => 3, 2 => 4)

    h = codto(f, 1:8)
    @test dom(h) == tinyset(2,7)
    @test cod(h) == tinyset(1,2,3)
    @test h == tinymap(tinyset(1,2,3), 2 => 2, 7 => 3) 
end

include("boolean.jl")
include("composition.jl")

function composition_tests(r, s, t)
    @test r^0 == eye(r)
    @test r^1 == r
    @test r^2 == r ∘ r
    @test r^3 == r ∘ r ∘ r
end

function diagonal_tests{N}(A::ExPart{N}, R::ExRelation{N})
    @test diagr(zero(A)) == zero(R)
    @test diagr(one(A)) == eye(A) == eye(R)
    @test diag(zero(R)) == zero(A)
    @test diag(one(R)) == one(A)
    @test diag(diagr(A)) == A
    @test diagr(diag(R)) ⊆ R
end

# indexing_tests
#        @test ((j,k) ∈ r) == (r[j,k] == 1)
#        @test ((j,k) ∈ r) == (k ∈ r[j,:]) == (r[j,:][k] == 1)
#        @test ((j,k) ∈ r) == (j ∈ r[:,k]) == (r[:,k][j] == 1)
# implement membership test (again) but not indexing

function opposite_tests{N}(r::ExRelation{N}, a::ExPart{N})
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

function each_tests{N}(A::ExPart{N}, R::ExRelation{N})
    @test length(zero(A)) == length(Set(each(Int, zero(A)))) == 0
    @test length(zero(R)) == length(Set(each(Int, zero(R)))) == 0
    @test length(one(A)) == length(Set(each(Int, one(A)))) == N
    @test length(one(R)) == length(Set(each(Int, one(R)))) == N^2
    @test length(ExPart{N}) == 2^N
    @test length(ExRelation{N}) == 2^(N^2)
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

    info("Composition tests on random 3-relations")
    composition_tests(r, s, t)

    info("Diagonal tests on a random 3-part and 3-relation")
    diagonal_tests(a, r)

    info("Opposite tests on a random 3-relation and 3-part")
    opposite_tests(r, a)

    info("Product tests on random 3-parts")
    product_tests(a, b)

    info("Each-tests on a random 3-part and 3-relation")
    each_tests(a, r)

    info("Point-tests on a random 3-part and 3-relation")
    point_tests(a, r)
end
