elem(::Type{Int}, k::Int) = k
elem(::Type{Char}, k::Int) = "abcdefgh"[k]
elem(::Type{Symbol}, k::Int) = [:a,:b,:c,:d,:e,:f,:g,:h][k]

### Iterate over all elements of a set
### - each(Int, randp(3))
### - each(Char, randp(3))

bitstype 8 TinyElemIter{N,T}

function each{N,T}(::Type{T}, pt::ExPart{N})
    reinterpret(TinyElemIter{N,T}, pt)
end

function start{N}(eit::TinyElemIter{N})
    pt = reinterpret(ExPart{N}, eit)
    for k in 1:N
        k in pt && return k
    end
    return N + 1
end

done{N,T}(eit::TinyElemIter{N,T}, state::Int) = state == N + 1

function next{N,T}(eit::TinyElemIter{N,T}, state::Int)
    pt = reinterpret(ExPart{N}, eit)
    this = state
    for k in (this + 1):N
        k in pt && return elem(T, this), k
    end
    return elem(T, this), N + 1
end

eltype{N,T}(::Type{TinyElemIter{N,T}}) = T

### Iterate over all pairs in a relation
### - each(Int, randr(3))
### - each(Char, randr(3))

bitstype 64 TinyPairIter{N,T}

function each{N,T}(::Type{T}, rn::ExRelation{N})
    reinterpret(TinyPairIter{N,T}, rn)
end

function start{N}(pit::TinyPairIter{N})
    rn = reinterpret(ExRelation{N}, pit)
    for r in 1:N
        for k in 1:N
            (r,k) in rn && return (r,k)
        end
    end
    return (N + 1, N + 1)
end

function done{N,T}(pit::TinyPairIter{N,T}, state::Tuple{Int,Int})
    state == (N + 1, N + 1)
end

function next{N,T}(pit::TinyPairIter{N,T}, state::Tuple{Int,Int})
    rn = reinterpret(ExRelation{N}, pit)
    r0, k0 = state
    item = (elem(T, r0), elem(T, k0))
    for k in (k0 + 1):N
        (r0,k) in rn && return item, (r0,k)
    end
    for r in (r0 + 1):N
        for k in 1:N
            (r,k) in rn && return item, (r,k)
        end
    end
    return item, (N + 1, N + 1)
end

eltype{N,T}(::Type{TinyPairIter{N,T}}) = Tuple{T,T}

### Iterate over all parts - this is *it*, almost.

start{N}(::Type{ExPart{N}}) = zero(UInt)
done{N}(::Type{ExPart{N}}, state::UInt) = state == one(UInt) << N
function next{N}(::Type{ExPart{N}}, state::UInt)
    reinterpret(ExPart{N}, UInt8(state)), state + one(UInt)
end

eltype{N}(::Type{ExPart{N}}) = ExPart{N}

# How could Relation state be large enough to accommodate one more
# value than there are relations? Refuse to iterate over them all?
# Use UInt128.

start{N}(::Type{ExRelation{N}}) = zero(UInt128)

function done{N}(::Type{ExRelation{N}}, state::UInt128)
    state == one(UInt128) << N^2
end

function next{N}(::Type{ExRelation{N}}, state::UInt128)
    reinterpret(ExRelation{N}, UInt64(state)), state + one(UInt128)
end

eltype{N}(::Type{ExRelation{N}}) = ExRelation{N}
