include("TinySets.jl")

module TinyTest

using TinySets

G = Dict{Bool,ASCIIString}(true => "PASS", false => "FAIL")
function gradeln(expression, success)
    println("$(G[success])\t$expression")
end

function latticy(t)
    println("=== Boolean lattice ===")
    x, y, z = sort(collect(keys(t)))
    u, v, w = t[x], t[y], t[z]
    print("let $x = ") ; showcompact(u) ; println()
    print("let $y = ") ; showcompact(v) ; println()
    print("let $z = ") ; showcompact(w) ; println()
    gradeln("$x == $x", u == u)
    gradeln("$x ⊆ $x", u ⊆ u)
    gradeln("$x ⊆ $x ∪ $z", u ⊆ u ∪ w)
    gradeln("$x ∩ $z ⊆ $x", u ∩ w ⊆ u)
    gradeln("$x ∩ $x == $x", u ∩ u == u)
    gradeln("$x ∪ $x == $x", u ∪ u == u)
    gradeln("$x ∩ one($x) == $x", u ∩ one(u) == u)
    gradeln("$x ∪ zero($x) == $x", u ∪ zero(u) == u)
    gradeln("$x - $x == zero($x)", u - u == zero(u))
    gradeln("$x - zero($x) == $x", u - zero(u) == u)
    gradeln("$x ∩ ~$x == zero($x)", u ∩ ~u == zero(u))
    gradeln("$x ∪ ~$x == one($x)", u ∪ ~u == one(u))
    gradeln("~~$x == $x", ~~u == u)
    gradeln("$x ∩ $z == $z ∩ $x", u ∩ w == w ∩ u)
    gradeln("$x ∪ $z == $z ∪ $x", u ∪ w == w ∪ u)
    gradeln("$x ∩ ($x ∪ $z) == $x", u ∩ (u ∪ w) == u)
    gradeln("$x ∪ ($x ∩ $z) == $x", u ∪ (u ∩ w) == u)
    gradeln("$x ∩ ($y ∪ $z) == ($x ∩ $y) ∪ ($x ∩ $z)",
            u ∩ (v ∪ w) == (u ∩ v) ∪ (u ∩ w))
    gradeln("$x ∪ ($y ∩ $z) == ($x ∪ $y) ∩ ($x ∪ $z)",
            u ∪ (v ∩ w) == (u ∪ v) ∩ (u ∪ w))
    gradeln("$x ∩ ($y ∩ $z) == ($x ∩ $y) ∩ $z",
            u ∩ (v ∩ w) == (u ∩ v) ∩ w)
    gradeln("$x ∪ ($y ∪ $z) == ($x ∪ $y) ∪ $z",
            u ∪ (v ∪ w) == (u ∪ v) ∪ w)
    println()
end

function transposy(R)
    println("== Opposite relation, indexing ===")
    print("let R = ") ; showcompact(R) ; println()
    gradeln("R'' == R", R'' == R)
    println("k ∈ R[j,:] for j in 1:3, k in 1:3")
    gradeln("<=> j ∈ R[:,k]",
            all(Bool[(k ∈ R[j,:]) == (j ∈ R[:,k]) # need the ()!
                     for j in 1:3, k in 1:3]))
    gradeln("<=> (j,k) ∈ R",
            all(Bool[(j ∈ R[:,k]) == ((j,k) ∈ R)
                     for j in 1:3, k in 1:3]))
    gradeln("<=> (k,j) ∈ R'",
            all(Bool[((j,k) ∈ R) == ((k,j) ∈ R')
                     for j in 1:3, k in 1:3]))
    gradeln("<=> j ∈ R'[k,:]",
            all(Bool[((k,j) ∈ R') == (j ∈ R'[k,:])
                     for j in 1:3, k in 1:3]))
    gradeln("<=> k ∈ R'[:,j]",
            all(Bool[(j ∈ R'[k,:]) == (k ∈ R'[:,j])
                     for j in 1:3, k in 1:3]))
    println()
end

function monoidy(t)
    println("=== Composition is a monoid ===")
    x, y, z = sort(collect(keys(t)))
    u, v, w = t[x], t[y], t[z]
    print("let $x = ") ; showcompact(u) ; println()
    print("let $y = ") ; showcompact(v) ; println()
    print("let $z = ") ; showcompact(w) ; println()
    gradeln("eye($x) ∘ $x == $x == $x ∘ eye($x)",
            eye(u) ∘ u == u == u ∘ eye(u))
    gradeln("$x ∘ ($y ∘ $z) == ($x ∘ $y) ∘ $z",
            u ∘ (v ∘ w) == (u ∘ v) ∘ w)
    println()
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
latticy(pd)
producty(pd[:y], pd[:z])

rd = Dict(:r => randr(3),
          :s => randr(3),
          :t => randr(3))
latticy(rd)
monoidy(rd)
transposy(rd[:r])
pointy(pd[:x], rd[:r])
diagonally(pd[:x], rd[:r])
eachy(pd[:x], rd[:r])
end

end
