# investigating nesting: permutations of combinations (they have
# combination and permutations in Base! also partitions) and so now
# also investigating permutations of partitions! amazing.

import Base: length, eltype, start, done, next

immutable Injections{T}
    dom::Int
    cod::Vector{T}
end

"""
    injections(codomain, n)
Generate all permutations of all combinations of `n` elements from an
indexable object. (It actually collects the codomain. Should it not?)
"""
injections(cod, n) = Injections(n, collect(cod))

function length(iter::Injections)
    cod = length(iter.cod)
    dom = iter.dom
    cod < dom ? 0 : div(factorial(cod), factorial(cod - dom))
end
eltype{T}(iter::Injections{T}) = Vector{T}

function start(iter::Injections)
    combiter = combinations(iter.cod, iter.dom)
    combstate = start(combiter)
    if done(combiter, combstate)
        # do protocol to manufacture a done permstate
        permiter = permutations(())
        empty, permstate = next(permiter, start(permiter))
    else
        comb, combstate = next(combiter, combstate)
        permiter = permutations(comb)
        permstate = start(permiter)
    end
    permiter, permstate, combiter, combstate
end
function done(iter::Injections, state)
    permiter, permstate, combiter, combstate = state
    done(permiter, permstate) && done(combiter, combstate)
end
function next{T}(iter::Injections{T}, state)
    permiter, permstate, combiter, combstate = state
    if done(permiter, permstate) 
        comb, combstate = next(combiter, combstate)
        permiter = permutations(comb)
        permstate = start(permiter)
    end
    perm, permstate = next(permiter, permstate)
    perm, (permiter, permstate, combiter, combstate)
end

immutable Surjections{T}
    dom::Vector{T}
    cod::Int
end

"""
    surjections(domain, n)
Generate all permutations of all partitions into `n` blocks from an
indexable object. (It actually collects the domain. Should it not?)
"""
surjections(dom, n) = Surjections(collect(dom), n)

function length(iter::Surjections)
    dom = iter.dom
    cod = iter.cod
    length(partitions(dom, cod)) * factorial(cod)
end
eltype{T}(iter::Surjections{T}) = Vector{Vector{T}}

function start(iter::Surjections)
    pioniter = partitions(iter.dom, iter.cod)
    pionstate = start(pioniter)
    if done(pioniter, pionstate)
        # do protocol to manufacture a done permstate
        permiter = permutations(())
        empty, permstate = next(permiter, start(permiter))
    else
        pion, pionstate = next(pioniter, pionstate)
        permiter = permutations(pion)
        permstate = start(permiter)
    end
    permiter, permstate, pioniter, pionstate
end
function done(iter::Surjections, state)
    permiter, permstate, pioniter, pionstate = state
    done(permiter, permstate) && done(pioniter, pionstate)
end
function next{T}(iter::Surjections{T}, state)
    permiter, permstate, pioniter, pionstate = state
    if done(permiter, permstate) 
        pion, pionstate = next(pioniter, pionstate)
        permiter = permutations(pion)
        permstate = start(permiter)
    end
    perm, permstate = next(permiter, permstate)
    perm, (permiter, permstate, pioniter, pionstate)
end
