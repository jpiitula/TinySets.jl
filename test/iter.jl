using TinySets
using Base.Test

# https://github.com/JuliaLang/Combinatorics.jl/blob/master/test/partitions.jl
# tests adapted for TinySets.partitions0 (by appending the 0) that
# uses Base.partitions when no empty or 0. Oh - TinySets.partitions0
# does only a fixed number of blocks, so adapt further.

@test collect(TinySets.partitions0([1,2,3], 0)) == Any[]
@test collect(TinySets.partitions0([1,2,3], 1)) == Any[Any[[1,2,3]]]
@test collect(TinySets.partitions0([1,2,3], 2)) == Any[Any[[1,2],[3]], Any[[1,3],[2]], Any[[1],[2,3]]]
@test collect(TinySets.partitions0([1,2,3], 3)) == Any[Any[[1],[2],[3]]]
@test collect(TinySets.partitions0([1,2,3], 4)) == Any[]

@test collect(TinySets.partitions0([1,2,3,4],3)) == Any[Any[[1,2],[3],[4]], Any[[1,3],[2],[4]], Any[[1],[2,3],[4]],
                                              Any[[1,4],[2],[3]], Any[[1],[2,4],[3]], Any[[1],[2],[3,4]]]
@test collect(TinySets.partitions0([1,2,3,4],1)) == Any[Any[[1, 2, 3, 4]]]
@test collect(TinySets.partitions0([1,2,3,4],5)) == []

@test length(collect(TinySets.partitions0('a':'h',0))) == length(TinySets.partitions0('a':'h',0))
@test length(collect(TinySets.partitions0('a':'h',5))) == length(TinySets.partitions0('a':'h',5))
@test length(collect(TinySets.partitions0('a':'h',9))) == length(TinySets.partitions0('a':'h',9))

# And have an own pair of tests.

@test collect(TinySets.partitions0(Char[], 0)) == Vector{Char}[[]]
@test collect(TinySets.partitions0(Char[], 1)) == Vector{Char}[]

# Then at last have actual TinySets tests, on injections and
# surjections. Hm, no, these are still potentially Combinatorics
# tests. TinySets tests will be on eachmono and eachepi instead.

let
    # injections to given codomain from domain of given size
    @test length(collect(injections("abcde", 3))) == 60
    @test length(collect(injections("abc", 3))) == 6
    @test length(collect(injections("abc", 4))) == 0
    @test length(collect(injections("abc", 0))) == 1
    @test length(collect(injections("", 0))) == 1
    @test length(collect(injections("", 1))) == 0

    @test eltype(injections("", 0)) == Vector{Char}
    @test eltype(injections("x", 1)) == Vector{Char}

    # surjections from given domain to codomain of given size
    @test length(collect(surjections("abcde", 3))) == 150
    @test length(collect(surjections("abc", 3))) == 6
    @test length(collect(surjections("abc", 4))) == 0

    # Julia Base.partitions(array, n) has trouble with empties so that
    # the following three are "domain errors" -- in Combinatorics in a
    # newer Julia but probably still the same -- so surjections uses a
    # wrapper in TinySets called partitions0.

    @test length(collect(surjections("", 0))) == 1
    @test length(collect(surjections("", 1))) == 0
    @test length(collect(surjections("x", 0))) == 0

    @test eltype(surjections("", 0)) == Vector{Vector{Char}}
    @test eltype(surjections("", 1)) == Vector{Vector{Char}}
    @test eltype(surjections("x", 1)) == Vector{Vector{Char}}
end
