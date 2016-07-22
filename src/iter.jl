# more general than tiny maps - could be in a separate library - has
# to work around a misfeature in Base.partitions (probably still
# present in Combinatorics.partitions, hope they think it a bug)

immutable Injections{T}
    dom::Int
    cod::Vector{T}
end

immutable Surjections{T}
    dom::Vector{T}
    cod::Int
end

"""
    TinySet.partitions0(array, n)
Works around a misfeature where Base.partitions throws Domain Error
for empty data or 0-block request. The correct handling is to generate
a 0-block partition for empty data, and no partitions for the other
cases.
"""

function partitions0{T}(array::AbstractArray{T}, n)
    if isempty(array) && n == 0
        Vector{T}[[]]
    elseif isempty(array) || n == 0
        Vector{T}[]
    else
        partitions(array, n)
    end
end

"""
    injections(codomain, n)
Generate permutations of `n`-element combinations.
"""
injections(cod, n) = Injections(n, collect(cod))

"""
    surjections(domain, n)
Generate permutations of `n`-blocks partitions.
"""
surjections(dom, n) = Surjections(collect(dom), n)

function length(iter::Injections)
    dom, cod = iter.dom, length(iter.cod)
    cod < dom ? 0 : factorial(cod, cod - dom)
end

function length(iter::Surjections)
    dom, cod = iter.dom, iter.cod
    length(partitions0(dom, cod)) * factorial(cod)
end

eltype{T}(iter::Injections{T}) = Vector{T}
eltype{T}(iter::Surjections{T}) = Vector{Vector{T}}

typealias Cancelables{T} Union{Injections{T},Surjections{T}}

start(iter::Injections) = start(iter, combinations(iter.cod, iter.dom))
start(iter::Surjections) = start(iter, partitions0(iter.dom, iter.cod))
function start(iter::Cancelables, mainiter)
    mainstate = start(mainiter)
    if done(mainiter, mainstate)
        # manufacture done state
        permiter = permutations(())
        empty, permstate = next(permiter, start(permiter))
    else
        main, mainstate = next(mainiter, mainstate)
        permiter = permutations(main)
        permstate = start(permiter)
    end
    permiter, permstate, mainiter, mainstate
end
function done(iter::Cancelables, state)
    permiter, permstate, mainiter, mainstate = state
    done(permiter, permstate) && done(mainiter, mainstate)
end
function next{T}(iter::Cancelables{T}, state)
    permiter, permstate, mainiter, mainstate = state
    if done(permiter, permstate) 
        main, mainstate = next(mainiter, mainstate)
        permiter = permutations(main)
        permstate = start(permiter)
    end
    perm, permstate = next(permiter, permstate)
    perm, (permiter, permstate, mainiter, mainstate)
end
