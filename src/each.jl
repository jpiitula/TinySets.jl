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
