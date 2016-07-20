"Constants part of an iteration state"
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
