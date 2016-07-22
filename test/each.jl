using TinySets
using Base.Test

let
    a, b = rand(TinySet), rand(TinySet)
    @test all(ismono, eachmono(a, b))
    @test all(ismono, eachmono(b, a))
end

@test length(eachmono(tinyset(), rand(TinySet))) == 1
@test first(eachmono(tinyset(), tinyset())) == tinymap(tinyset())
@test first(eachmono(tinyset(), tinyset(3))) == tinymap(tinyset(3))
