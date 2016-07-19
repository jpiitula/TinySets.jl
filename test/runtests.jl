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
@test eltype(tinyset()) == Int
@test length(tinyset()) == 0
@test isempty(tinyset())
@test collect(tinyset()) == Int[]
@test eltype(tinyset(3,1,4)) == Int
@test length(tinyset(3,1,4)) == 3
@test !isempty(tinyset(3,1,4))
@test collect(tinyset(3,1,4)) == [1,3,4]
@test dom(tinymap(can(3))) == tinyset()
@test cod(tinymap(can(3))) == can(3)
@test dom(tinymap(can(3), 1 => 2)) == can(1)
@test cod(tinymap(can(3), 1 => 2)) == can(3)
@test tinymap(can(3)) == tinymap(can(3))
@test tinymap(can(3)) != tinymap(can(3), 1 => 2)
@test id(can(3)) == tinymap(can(3), 1 => 1, 2 => 2, 3 => 3)
@test isempty(tinymap(can(5)))
@test length(tinymap(can(5))) == 0
@test eltype(tinymap(can(5))) == Pair{Int,Int}
@test collect(tinymap(can(5))) == Pair{Int,Int}[]
@test !isempty(tinymap(can(5), 3 => 1, 1 => 3, 4 => 4))
@test length(tinymap(can(5), 3 => 1, 1 => 3, 4 => 4)) == 3
@test eltype(tinymap(can(5), 3 => 1, 1 => 3, 4 => 4)) == Pair{Int,Int}
@test (collect(tinymap(can(5), 3 => 1, 1 => 3, 4 => 4)) ==
       Pair[1 => 3, 3 => 1, 4 => 4])
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
@test ismono(randmono(can(3), can(4)))
@test isepi(randepi(can(4), can(3)))
@test isiso(randiso(can(4), can(4)))
info("=== new start tests done ===")

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

let
    a = rand(TinySet)
    b = rand(TinySet)
    c = rand(TinySet)
    d = rand(TinySet)
    r = randrelation(a, b)
    s = randrelation(b, c)
    t = randrelation(c, d)
    @test graph(id(cod(r))) ∘ r == r
    @test r ∘ graph(id(dom(r))) == r
    @test r == r''
    @test (s ∘ r)' == r' ∘ s'
    @test t ∘ (s ∘ r) == (t ∘ s) ∘ r
    while isempty(a) < isempty(b)
        b = rand(TinySet)
    end
    while isempty(b) < isempty(c)
        c = rand(TinySet)
    end
    while isempty(c) < isempty(d)
        d = rand(TinySet)
    end
    f = randmap(a, b)
    g = randmap(b, c)
    h = randmap(c, d)
    @test id(cod(f)) ∘ f == f
    @test f ∘ id(dom(f)) == f
    @test h ∘ (g ∘ f) == (h ∘ g) ∘ f

    i = codto(d, shuffle(collect(1:8)))
    i ∘ i' == id(dom(i))
    i' ∘ i == id(cod(i))

    j = domto(d, shuffle(collect(1:8)))
    j ∘ j' == id(dom(j))
    j' ∘ j == id(cod(j))
end

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

function indexing_tests{N}(r::ExRelation{N})
    for j in 1:N, k in 1:N
        @test ((j,k) ∈ r) == (r[j,k] == 1)
        @test ((j,k) ∈ r) == (k ∈ r[j,:]) == (r[j,:][k] == 1)
        @test ((j,k) ∈ r) == (j ∈ r[:,k]) == (r[:,k][j] == 1)
    end
end

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
