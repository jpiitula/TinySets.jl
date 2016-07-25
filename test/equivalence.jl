let
    a = rand(TinySet)

    @test length(eachequivalence(a)) == length(eachpartition(a))

    e = randequivalence(a)
    @test graph(id(a)) ⊆ e
    @test e == e'
    @test e^2 ⊆ e
end
