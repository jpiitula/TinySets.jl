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

include("isomap.jl")

include("boolean.jl")
include("composition.jl")

include("product.jl")

let
    a = rand(TinySet)
    @test length(a) == length(collect(a))

    @test length(tinyset()) == 0
    @test length(collect(tinyset())) == 0

    @test length(tinyset(1:8)) == 8
    @test length(collect(tinyset(1:8))) == 8

    @test length(tinyset(3,1,4)) == 3
    @test length(collect(tinyset(3,1,4))) == 3
end

include("equivalence.jl")
