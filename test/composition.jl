using TinySets
using Base.Test

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
    info("nonempty to empty *can* happen! it *did* so fix test")
    f = randmap(a, b)
    g = randmap(b, c)
    h = randmap(c, d)
    @test id(cod(f)) ∘ f == f
    @test f ∘ id(dom(f)) == f
    @test h ∘ (g ∘ f) == (h ∘ g) ∘ f

    i = pairto(d, shuffle(collect(1:8)))
    i ∘ i' == id(dom(i))
    i' ∘ i == id(cod(i))

    j = pairfrom(d, shuffle(collect(1:8)))
    j ∘ j' == id(dom(j))
    j' ∘ j == id(cod(j))
end

let
    a = rand(TinySet)
    b = rand(TinySet)
    r = randrelation(a, b)
    @test r ∘ graph(id(a)) == r
    @test graph(id(b)) ∘ r == r
    @test (r ∘ graph(id(a)))' == r' ∘ graph(id(b))
    @test (graph(id(b)) ∘ r)' == graph(id(a)) ∘ r'
    for j in dom(r), k in cod(r)
        @test ((j,k) ∈ r) == ((k,j) ∈ r')
    end
end
