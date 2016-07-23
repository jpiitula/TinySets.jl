let
    A = rand(TinySet)
    B = rand(TinySet)
    @test A × B == reduce(∪, tinyrelation(A, B),
                          [ tinyrelation(A, B, tinyset(j) × B)
                            for j in A ])
    @test A × B == reduce(∪, tinyrelation(A, B),
                          [ tinyrelation(A, B, A × tinyset(k))
                            for k in B ])
    @test A × B == reduce(∪, tinyrelation(A, B),
                          [ tinyrelation(A, B, j => k)
                            for j in A, k in B ])
    @test A × B == (B × A)'
    @test length(tinyset() × B) == 0
    @test length(A × tinyset()) == 0
    @test length(tinyrelation(A, B)) == 0
    @test bot(A × B) == tinyrelation(A, B)
    @test top(A × B) == A × B

    # had something like this in the old design
    # @test isempty(A) || (A × B) ∘ one(A) == B
end
