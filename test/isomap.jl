let
    set = tinyset(3,1,4)

    f = pairfrom(set, 1:8)
    @test dom(f) == tinyset(1,2,3)
    @test cod(f) == tinyset(3,1,4)
    @test isiso(f)

    g = pairto(set, 1:8)
    @test dom(g) == tinyset(3,1,4)
    @test cod(g) == tinyset(1,2,3)
    @test isiso(g)
end

let
    f = tinymap(tinyset(3,1,4), 2 => 3, 7 => 4)

    g = pairfrom(f, 1:8)
    @test dom(g) == tinyset(1,2)
    @test cod(g) == tinyset(3,1,4)
    @test ismono(g)
    @test g == tinymap(cod(f), 1 => 3, 2 => 4)

    h = pairto(f, 1:8)
    @test dom(h) == tinyset(2,7)
    @test cod(h) == tinyset(1,2,3)
    @test h == tinymap(tinyset(1,2,3), 2 => 2, 7 => 3) 
end
