using TinySets
using Base.Test

@test length(tinyset()) == 0
@test length(tinyset(1:3)) == 3
@test length(tinyset(3,1,4)) == 3

@test tinyset(1:0) == tinyset()
@test tinyset(1:3) == tinyset(1,2,3)

@test eltype(tinyset()) == Int
@test eltype(tinyset(3,1,4)) == Int

@test isempty(tinyset())
@test !isempty(tinyset(3,1,4))

@test collect(tinyset()) == Int[]
@test collect(tinyset(3,1,4)) == [1,3,4]
