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

@test length(eachpart(tinyset())) == 1
@test length(collect(eachpart(tinyset()))) == 1
@test length(eachpart(tinyset(3,1,4))) == 8
@test length(collect(eachpart(tinyset(3,1,4)))) == 8
@test all(ismono, eachpart(tinyset()))
@test all(ismono, eachpart(tinyset(3,1,4)))

@test length(eachpartition(tinyset())) == 1
@test length(collect(eachpartition(tinyset()))) == 1
@test length(eachpartition(tinyset(3,1,4))) == 5
@test length(collect(eachpartition(tinyset(3,1,4)))) == 5
@test all(isepi, eachpartition(tinyset()))
@test all(isepi, eachpartition(tinyset(3,1,4)))

let
    a, b = rand(TinySet), rand(TinySet)
    @test all(isepi, eachepi(a, b))
    @test all(isepi, eachepi(b, a))
end

@test length(eachepi(tinyset(2,5), tinyset(3))) == 1
@test (first(eachepi(tinyset(2,5), tinyset(3))) ==
       tinymap(tinyset(3), 2=>3, 5=>3))
@test length(eachepi(tinyset(), tinyset())) == 1
@test first(eachepi(tinyset(), tinyset())) == tinymap(tinyset())
@test length(eachepi(tinyset(), tinyset(3))) == 0
@test length(collect(eachepi(tinyset(), tinyset(3)))) == 0
