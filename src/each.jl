"Constant part of an iteration state"
immutable EachMap
    dom::TinySet
    cod::TinySet
    inputs::Vector{Int}
    outputs::Vector{Int}
    n::Int
end

function eachmap(dom::TinySet, cod::TinySet)
    EachMap(dom, cod,
            collect(dom), collect(cod),
            length(cod)^length(dom))
end

length(hom::EachMap) = hom.n
eltype(hom::EachMap) = TinyMap
start(hom::EachMap) = (0, ntuple(j -> 1, length(hom.inputs)))
function done(hom::EachMap, state)
    k,ix = state
    k == hom.n
end
function next(hom::EachMap, state)
    k,ix = state
    m = length(hom.outputs)
    j = findfirst(d -> d < m, ix)
    jx = ntuple(t -> (t < j) ? 1 : (t == j) ? ix[t] + 1 : ix[t],
                length(hom.inputs))
    rule = zero(UInt64)
    for (input,d) in zip(hom.inputs, ix)
        rule = setbit(rule, input, hom.outputs[d])
    end
    TinyMap(rule, hom.dom, hom.cod), (k + 1, jx)
end

immutable EachMono
    dom::TinySet
    cod::TinySet
end

"""
    eachmono(dom::TinySet, cod::TinySet)
Generate monomaps from `dom` to `cod`.
"""
eachmono(dom::TinySet, cod::TinySet) = EachMono(dom, cod)

function length(hom::EachMono)
    dom, cod = length(hom.dom), length(hom.cod)
    cod < dom ? 0 : factorial(cod, cod - dom)
end
eltype(hom::EachMono) = TinyMap

function start(hom::EachMono)
    iter = injections(collect(hom.cod), length(hom.dom))
    iter, start(iter)
end
function done(hom::EachMono, state)
    iter, iterstate = state
    done(iter, iterstate)
end
function next(hom::EachMono, state)
    iter, iterstate = state
    target, iterstate = next(iter, iterstate)
    rule = zero(UInt64)
    for (input,output) in zip(hom.dom, target)
        rule = setbit(rule, input, output)
    end
    TinyMap(rule, hom.dom, hom.cod), (iter, iterstate)
end

immutable EachEpi
    dom::TinySet
    cod::TinySet
end

eachepi(dom::TinySet, cod::TinySet) = EachEpi(dom, cod)

length(hom::EachEpi) = length(surjections(collect(hom.dom), length(hom.cod)))
eltype(hom::EachEpi) = TinyMap

function start(hom::EachEpi)
    iter = surjections(hom.dom, length(hom.cod)) # it does collect, ok?
    iter, start(iter)
end
function done(hom::EachEpi, state)
    iter, iterstate = state
    done(iter, iterstate)
end
function next(hom::EachEpi, state)
    iter, iterstate = state
    target, iterstate = next(iter, iterstate)
    rule = zero(UInt64)
    for (inputs,output) in zip(target, hom.cod)
        for input in inputs
            rule = setbit(rule, input, output)
    end end
    TinyMap(rule, hom.dom, hom.cod), (iter, iterstate)
end

"Constant part of an iteration state"
immutable EachRelation
    dom::TinySet
    cod::TinySet
    inputs::Vector{Int}
    outputs::Vector{Int}
    n::UInt128
end

function eachrelation(dom::TinySet, cod::TinySet)
    EachRelation(dom, cod,
                 collect(dom), collect(cod),
                 one(UInt128) << (length(dom) * length(cod)))
end

length(hom::EachRelation) = hom.n
eltype(hom::EachRelation) = TinyRelation
start(hom::EachRelation) = zero(UInt128)
done(hom::EachRelation, state) = state == hom.n
function next(hom::EachRelation, state)
    (TinyRelation(unpack(hom, state), hom.dom, hom.cod),
     state + one(UInt128))
end

function unpack(hom::EachRelation, state)
    inputs, outputs = hom.inputs, hom.outputs
    m, n = length(hom.dom), length(hom.cod)
    rule = zero(UInt64)
    for r in 1:m
        packed = UInt((state >> ((r - 1) * n)) & 0xff)
        for k in 1:n
            if (packed & (one(UInt) << (k - 1))) > zero(UInt)
                rule = setbit(rule, inputs[r], outputs[k])
    end end end
    rule
end
