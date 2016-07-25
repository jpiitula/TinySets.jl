# Copyright 2016 Jussi Piitulainen; free under GPLv3+, no warranty

"""
    rand(TinySet)::TinySet

One of the 256 possible tiny sets at random.
"""

rand(::Type{TinySet}) = reinterpret(TinySet, rand(UInt8))

"""
    randpart(cod::TinySet)::TinyMap

A random canonical part of the given codomain (a tiny monomap with
that codomain and an identity rule as a representative of an
equivalence class).
"""

function randpart(cod::TinySet)
    res = reinterpret(TinySet, rand(UInt8) & reinterpret(UInt8, cod))
    TinyMap(ruleof(res), res, cod)
end

"""
    randpartition(dom::TinySet)

A random canonical partition of the given domain (an epimap with that
domain and what rule exactly as a representative of an equivalence
class).
"""

function randpartition(dom::TinySet)
    isempty(dom) && return tinymap(dom)
    boxen = bellboxen(length(dom); least = first(dom))
    rule = zero(UInt64)
    for (k,b) in zip(dom, boxen)
        rule = setbit(rule, k, b)
    end
    TinyMap(rule, dom, reinterpret(TinySet, image(rule)))
end

"""
    randrelation(dom::TinySet, cod::TinySet)
"""

function randrelation(dom::TinySet, cod::TinySet)
    rule, mask = rand(UInt64), zero(UInt64)
    good = UInt64(reinterpret(UInt8, cod))
    for row in dom
        mask |= good << (8 * (row - 1))
    end
    TinyRelation(rule & mask, dom, cod)
end

function randequivalence(dom::TinySet)
    pion = randpartition(dom)
    rule = zero(UInt64)
    for block in [ preimage(pion, tinyset(box)) for box in cod(pion) ]
        for input in block, output in block
            rule = setbit(rule, input, output)
    end end
    TinyRelation(rule, dom, dom)
end

function randmap(dom::TinySet, cod::TinySet)
    isempty(dom) <= isempty(cod) || error("no such map")
    rule = zero(UInt64)
    output = collect(cod)
    for input in dom
        rule = setbit(rule, input, rand(output))
    end
    TinyMap(rule, dom, cod)
end

function randmono(dom::TinySet, cod::TinySet)
    length(dom) <= length(cod) || error("no such map")
    rule = zero(UInt64)
    output = shuffle!(collect(cod))
    for (k,input) in enumerate(dom)
        rule = setbit(rule, input, output[k])
    end
    TinyMap(rule, dom, cod)
end

function randepi(dom::TinySet, cod::TinySet)
    length(dom) >= length(cod) || error("no such map")
    values = collect(cod)
    rest = [ rand(values) for k in 1:(length(dom) - length(cod)) ]
    append!(values, rest)
    shuffle!(values)
    rule = zero(UInt64)
    for (input,output) in zip(dom,values)
         rule = setbit(rule, input,output)
    end
    TinyMap(rule, dom, cod)
end

function randiso(dom::TinySet, cod::TinySet)
    length(dom) == length(cod) || error("no such map")
    rule = zero(UInt64)
    for (input,output) in zip(dom,shuffle!(collect(cod)))
        rule = setbit(rule, input, output)
    end
    TinyMap(rule, dom, cod)
end
