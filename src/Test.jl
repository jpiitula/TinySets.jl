include("TinySets.jl")

module TinyTest

using TinySets

G = Dict{Bool,ASCIIString}(true => "PASS", false => "FAIL")
function gradeln(expression, success)
    println("$(G[success])\t$expression")
end

function producty(y, z)
    println("== Product, each of part, opposite, projection ===")
    print("let y = ") ; showcompact(y) ; println()
    print("let z = ") ; showcompact(z) ; println()
    gradeln("y × z == ⋃ ({k} × z), k ∈ y",
            y × z == reduce(∪, zero(y × z),
                            map(k -> k × z,
                                each(Int, y))))
    gradeln("y × z == ⋃ (y × {k}), k ∈ z",
            y × z == reduce(∪, zero(y × z),
                            map(k -> y × k,
                                each(Int, z))))
    gradeln("y × z == (z × y)'", y × z == (z × y)')
    gradeln("zero(y) × z == zero(y × z) == y × zero(z)",
            zero(y) × z == zero(y × z) == y × zero(z))
    gradeln("one(y) × one(z) == one(y × z)",
            one(y) × one(z) == one(y × z))
    gradeln("z == {} or y == (y × z) ∘ one(z)",
            z == zero(z) || y == (y × z) ∘ one(z))
    gradeln("y == {} or z == one(y) ∘ (y × z)",
            y == zero(y) || z == one(y) ∘ (y × z))
    println()
end

function pointy(A, R)
    println("== Points, each of part and relation ===")
    print("let A = ") ; showcompact(A) ; println()
    print("let R = ") ; showcompact(R) ; println()
    gradeln("A == ⋃ {k}, k ∈ A",
            A == reduce(∪, zero(A),
                        map(k -> point(A, k), each(Int, A))))
    gradeln("R == ⋃ {(j,k)}, (j,k) ∈ R",
            R == reduce(∪, zero(R),
                        map(p -> point(R, p...), each(Int, R))))
    gradeln("|A| == |{k : k ∈ A}|",
            length(A) == length(Set(each(Int, A))))
    gradeln("|R| == |{p : p ∈ R}|",
            length(R) == length(Set(each(Int, R))))
    gradeln("|one(A)| == |{k : k ∈ one(A)}|",
            length(one(A)) == length(Set(each(Int, one(A)))))
    gradeln("|one(R)| == |{k : k ∈ one(R)}|",
            length(one(R)) == length(Set(each(Int, one(R)))))
    gradeln("|zero(A)| == |{k : k ∈ zero(A)}| == 0",
            length(zero(A)) == length(Set(each(Int, zero(A)))) == 0)
    gradeln("|zero(R)| == |{k : k ∈ zero(R)}| == 0",
            length(zero(R)) == length(Set(each(Int, zero(R)))) == 0)
    println()
end

function diagonally(A, R)
    println("== Diagonals ===")
    print("let A = ") ; showcompact(A) ; println()
    print("let R = ") ; showcompact(R) ; println()
    gradeln("diagr(zero(A)) == zero(R)", diagr(zero(A)) == zero(R))
    gradeln("diagr(one(A)) == eye(A) == eye(R)",
            diagr(one(A)) == eye(A) == eye(R))
    gradeln("diag(zero(R)) == zero(A)", diag(zero(R)) == zero(A))
    gradeln("diag(one(R)) == one(A)", diag(one(R)) == one(A))
    gradeln("diag(diagr(A)) == A", diag(diagr(A)) == A)
    gradeln("diagr(diag(R)) ⊆ R", diagr(diag(R)) ⊆ R)
    println()
end

function eachy(A, R)
    println("== Each ===")
    print("let A = ") ; showcompact(A) ; println()
    print("let R = ") ; showcompact(R) ; println()
    gradeln("length(A) == length(collect(each(Int, A)))",
            length(A) == length(collect(each(Int, A))))
    gradeln("length(A) == length(collect(each(Char, A)))",
            length(A) == length(collect(each(Char, A))))
    gradeln("length(A) == length(collect(each(Symbol, A)))",
            length(A) == length(collect(each(Symbol, A))))
    gradeln("length(R) == length(collect(each(Int, R)))",
            length(R) == length(collect(each(Int, R))))
    gradeln("length(R) == length(collect(each(Char, R)))",
            length(R) == length(collect(each(Char, R))))
    gradeln("length(R) == length(collect(each(Symbol, R)))",
            length(R) == length(collect(each(Symbol, R))))
    gradeln("length(TinyPart{3}) == 2^3 == 8",
            length(TinyPart{3}) == 2^3 == 8)
    gradeln("length(TinyRelation{3}) == 2^(3^2) == 512",
            length(TinyRelation{3}) == 2^(3^2) == 512)
end

let
pd = Dict(:x => randp(3),
          :y => randp(3),
          :z => randp(3))

producty(pd[:y], pd[:z])

rd = Dict(:r => randr(3),
          :s => randr(3),
          :t => randr(3))

pointy(pd[:x], rd[:r])
diagonally(pd[:x], rd[:r])
eachy(pd[:x], rd[:r])
end

end
