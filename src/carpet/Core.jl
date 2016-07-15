# Included in TinySets.jl

# Parsed and printed as bit patterns.

"""
    Pt"1011" :: ExPart{4}

A part of an `N`-element set

`Pt"1011"` stands for {1,3,4} as a part of the set {1,2,3,4}.

"""
macro Pt_str(s)
    # e.g. Pt"101" means {1, 3} as a part of {1,2,3}
    N = length(s)
    if N == 0
        ExPart(0, 0x0)
    else
        ExPart(N, parse(UInt8, s, 2))
    end
end

function Base.show{N}(io::Base.IO, pt::ExPart{N})
    bs = bits(reinterpret(UInt8, pt))[(end - N + 1):end]
    println(io, "Tiny $(N)-Part")
    println(io, "  $(join(bs, ' '))")
end

function Base.showcompact{N}(io::Base.IO, pt::ExPart{N})
    bs = bits(reinterpret(UInt8, pt))[(end - N + 1):end]
    print(io, "Pt\"$bs\"")
end

"""
    Rn"100 010 011" :: ExRelation{3}

A relation on an `N`-element set

`Rn"100 010 011"` denotes the relation {(1,1), (2,2), (3,2), (3,3)} on
the set {1,2,3}, row by row.

`Rn"10 01"` denotes the identity relation on {1,2}

"""
macro Rn_str(s)
    # e.g. 
    rows = split(s)
    N = length(rows)
    # assert all(map(row -> length(row) == N <= 8, rows))
    rep = parse(UInt64, join(rows), 2)
    reinterpret(ExRelation{N}, rep)
end

function Base.show{N}(io::Base.IO, rn::ExRelation{N})
    rep = bits(reinterpret(UInt64, rn))
    println(io, "Tiny $(N)-Relation")
    if N > 0
        for t in range(N^2, -N, N)
            bs = join(rep[(end - t + 1):(end - t + N)], ' ')
            println(io, "  $bs")
        end
    end
end

function Base.showcompact{N}(io::Base.IO, rn::ExRelation{N})
    rep = bits(reinterpret(UInt64, rn))
    rows = if N > 0 # step cannot be zero
               map(t -> join(rep[(end - t + 1):(end - t + N)]),
                   range(N^2, -N, N))
           else
               ASCIIString[]
           end
    print(io, "Rn\"$(join(rows, ' '))\"")
end

"""
    length(pt::ExPart{N})
"""
length{N}(pt::ExPart{N}) = count_ones(reinterpret(UInt8, pt))

"""
    length(rn::ExRelation{N})
"""
length{N}(rn::ExRelation{N}) = count_ones(reinterpret(UInt64, rn))

"""
    length(ExPart{N}) == 2^N

The number of parts of an `N`-element set.
"""
length{N}(::Type{ExPart{N}}) = 2^N

"""
    length(ExRelation{N}) == 2^(N^2)

The number of relation on an `N`-element set.
"""
length{N}(::Type{ExRelation{N}}) = 2^(N^2)

"""
    (pt :: ExPart{N})[k] :: Int

Indicate membership of `k` in `pt` by `1` or `0`

See also `k ∈ pt`.

"""
function getindex{N}(pt::ExPart{N}, k::Int)
    # check 1 <= k <= N
    Int((reinterpret(UInt8, pt) >> (N - k)) & one(UInt8))
end

"""
    (rn :: ExRelation{N})[r,k] :: Int

Indicate membership of `(r,k)` in `rn` by `1` or `0`.

See also `(r,k) ∈ rn`.

"""
function getindex{N}(rn::ExRelation{N}, r::Int, k::Int)
    rep = reinterpret(UInt64, rn)
    Int(0x1 & (rep >> (N * (N - r) + (N - k))))
end

function getindex{N}(rn::ExRelation{N}, r::Int, k::Colon)
    rep = reinterpret(UInt64, rn)
    reinterpret(ExPart{N},
                UInt8((one(UInt64) << N - 1) &
                      (rep >> (N * (N - r)))))
end

function getindex{N}(rn::ExRelation{N}, r::Colon, k::Int)
    function im(r)
        ((r,k) ∈ rn) ? point(ExPart{N}, r) : zero(ExPart{N})
    end
    reduce(∪, zero(ExPart{N}), map(im, 1:N))
end

### Creation methods

function point{N}(::Type{ExPart{N}}, k::Int)
    reinterpret(ExPart{N},
                one(UInt8) << (N - k))
end

function point{N}(pt::ExPart{N}, k::Int)
    point(typeof(pt), k)
end

function point{N}(::Type{ExRelation{N}}, r::Int, k::Int)
    reinterpret(ExRelation{N},
                one(UInt64) << (N * (N - r) + (N - k)))
end

function point{N}(rn::ExRelation{N}, r::Int, k::Int)
    point(typeof(rn), r, k)
end

function times{N}(r::Int, pt::ExPart{N})
    reinterpret(ExRelation{N},
                UInt64(reinterpret(UInt8, pt)) << (N * (N - r)))
end
×{N}(r::Int, pt::ExPart{N}) = times(r, pt)

function times{N}(pt::ExPart{N}, k::Int)
    im(r) = point(ExRelation{N}, r, k)
    reduce(∪, zero(ExRelation{N}), map(im, each(Int, pt)))
end
×{N}(pt::ExPart{N}, k::Int) = times(pt, k)

function times{N}(pt1::ExPart{N}, pt2::ExPart{N})
    im(r) = r × pt2
    reduce(∪, zero(ExRelation{N}), map(im, each(Int, pt1)))
end
×{N}(pt1::ExPart{N}, pt2::ExPart{N}) = times(pt1, pt2)

### Membership tests.

"""
    (k ∈ pt :: ExPart{N}) :: Bool

`True` if `k` is in the part `pt` of an `N`-element set
"""
function ∈{N}(k::Int, pt::ExPart{N})
    (reinterpret(UInt8, pt) >> (N - k)) & one(UInt8) == one(UInt8)
end

function ∈{N}(rk::Tuple{Int,Int}, rn::ExRelation{N})
    r, k = rk
    rep = reinterpret(UInt64, rn)
    (rep >> (N * (N - r) + (N - k))) & one(UInt64) == one(UInt64)
end

### Random parts and relations

"""
    randp(n::Int) :: ExPart{n}

Return a random part of an `n`-element set
"""
function randp(n::Int)
    reinterpret(ExPart{n},
                rand(zero(UInt8):(one(UInt8) << n - one(UInt8))))
end

"""
    randp(pt::ExPart{N}) :: ExPart{N}

Return a random part of an `N`-element set
"""
randp{N}(::ExPart{N}) = randp(N)

"""
    randp(rn::ExRelation{N}) :: ExPart{N}

Return a random part of an `N`-element set
"""
randp{N}(::ExRelation{N}) = randp(N)

"""
    randr(n::Int) :: ExRelation{n}

Return a random relation on an `n`-element set
"""
function randr(n::Int)
    reinterpret(ExRelation{n},
                rand(zero(UInt64):(one(UInt64) << n^2 - one(UInt64))))
end

"""
    randr(pt::ExPart{N}) :: ExRelation{N}

Return a random relation on an `N`-element set
"""
randr{N}(::ExPart{N}) = randr(N)

"""
    randr(rn::ExRelation{N}) :: ExRelation{N}

Return a random relation on an `N`-element set
"""
randr{N}(::ExRelation{N}) = randr(N)


### Composition and related operations.

"""
    (rn1 ∘ rn2) :: ExRelation{N}

Composition of relations on an `N`-element set

"""
function ∘{N}(rn1::ExRelation{N}, rn2::ExRelation{N})
    function im(r)
        pt = rn1[r,:] ∘ rn2
        reinterpret(ExRelation{N},
                    UInt64(reinterpret(UInt8, pt)) << ((N - r) * N))
    end
    reduce(∪, zero(ExRelation{N}), map(im, 1:N))
end

"""
    (pt ∘ rn) :: ExPart{N}

Image of a part of an `N`-element set along a relation

"""
function ∘{N}(pt::ExPart{N}, rn::ExRelation{N})
    im(k) = rn[k,:]
    reduce(∪, zero(ExPart{N}), map(im, each(Int, pt)))
end

"""
    (rn ∘ pt) :: ExPart{N}

Pre-image of a part of an `N`-element set along a relation

"""
function ∘{N}(rn::ExRelation{N}, pt::ExPart{N})
    im(r) = rn[:,r]
    reduce(∪, zero(ExPart{N}), map(im, each(Int, pt)))
end

"""
    R^n :: ExRelation{N}
"""
function Base.(:^){N}(m::ExRelation{N}, n::Int)
    # assert n >= 0
    it(k) = m
    reduce(∘, eye(typeof(m)), map(it, 1:n))
end

"""
    rn' :: ExRelation{N}
    ctranspose(rn)

Opposite relation on an `N`-element set
"""
function Base.ctranspose{N}(rn::ExRelation{N})
    T = typeof(rn)
    im(k) = times(k, rn[:,k])
    reduce(∪, zero(T), map(im, 1:N))
end

# diag : diagr cf. diag : diagm for matrices in Julia Base

"""
    diagr(pt::ExPart{N}) :: ExRelation{N}

Represent the part as a diagonal relation
"""
function diagr{N}(pt::ExPart{N})
    im(k) = ((k ∈ pt)
             ? reinterpret(ExRelation{N},
                           one(UInt64) << (N * (N - k) + (N - k)))
             : zero(ExRelation{N}))
    reduce(∪, zero(ExRelation{N}), map(im, 1:N))
end

"""
    diag(rn::ExRelation{N}) :: ExPart{N}

Extract the diagonal of the relation as a part

Use `diagr` to construct a diagonal relation.
"""
function diag{N}(rn::ExRelation{N})
    im(k) = (((k,k) ∈ rn)
             ? reinterpret(ExPart{N},
                           one(UInt8) << (N - k))
             : zero(ExPart{N}))
    reduce(∪, zero(ExPart{N}), map(im, 1:N))
end

Δ{N}(pt::ExPart{N}) = diagr(pt)
Δ{N}(rn::ExRelation{N}) = diag(rn)

"""
    eye(pt::ExPart{N}) :: ExRelation{N}

Identity relation
"""
eye{N}(::Type{ExPart{N}}) = diagr(one(ExPart{N}))
eye{N}(::Type{ExRelation{N}}) = eye(ExPart{N})
eye{N}(pt::ExPart{N}) = eye(ExPart{N})
eye{N}(rn::ExRelation{N}) = eye(ExRelation{N})

# Parts of a set form a Boolean lattice.
# Relations on a set form a Boolean lattice.

"""
    zero(ExPart{N})

Empty part
"""
function zero{N}(::Type{ExPart{N}})
    reinterpret(ExPart{N}, zero(UInt8))
end

"""
    zero(pt::ExPart{N})
"""
zero{N}(pt::ExPart{N}) = zero(typeof(pt))

"""
    zero(ExRelation{N})

Empty relation
"""
function zero{N}(::Type{ExRelation{N}})
    reinterpret(ExRelation{N}, zero(UInt64))
end

"""
    zero(rn::ExRelation{N})
"""
zero{N}(rn::ExRelation{N}) = zero(typeof(rn))

"""
    one(ExPart{N})

"Full" part with all `N` elements as members
"""
function one{N}(::Type{ExPart{N}})
    reinterpret(ExPart{N}, ~zero(UInt8) >> (8 - N))
end

one{N}(pt::ExPart{N}) = one(typeof(pt))

function one{N}(::Type{ExRelation{N}})
    reinterpret(ExRelation{N}, ~zero(UInt64) >> (64 - N * N))
end

one{N}(rn::ExRelation{N}) = one(typeof(rn))

"""
    pt1 ∪ pt2 :: ExPart{N}

Union of parts of an `N`-element set
"""
function ∪{N}(pt1::ExPart{N}, pt2::ExPart{N})
    reinterpret(ExPart{N},
                reinterpret(UInt8, pt1) |
                reinterpret(UInt8, pt2))
end

"""
    rn1 ∪ rn2 :: ExRelation{N}

Union of relations on an `N`-element set
"""
function ∪{N}(rn1::ExRelation{N}, rn2::ExRelation{N})
    reinterpret(ExRelation{N},
                reinterpret(UInt64, rn1) |
                reinterpret(UInt64, rn2))
end

"""
    pt1 ∩ p:: ExPart{N}

Intersection of parts of an `N`-element set
"""
function ∩{N}(pt1::ExPart{N}, pt2::ExPart{N})
    reinterpret(ExPart{N},
                reinterpret(UInt8, pt1) &
                reinterpret(UInt8, pt2))
end

"""
    pt1 ∩ pt2 :: ExRelation{N}

Intersection of relations on an `N`-element set
"""
function ∩{N}(rn1::ExRelation{N}, rn2::ExRelation{N})
    reinterpret(ExRelation{N},
                reinterpret(UInt64, rn1) &
                reinterpret(UInt64, rn2))
end

function Base.(:-){N}(pt1::ExPart{N}, pt2::ExPart{N})
    reinterpret(ExPart{N},
                reinterpret(UInt8, pt1) &
                ~reinterpret(UInt8, pt2))
end

function Base.(:-){N}(rn1::ExRelation{N}, rn2::ExRelation{N})
    reinterpret(ExRelation{N},
                reinterpret(UInt64, rn1) &
                ~reinterpret(UInt64, rn2))
end

"""
    ~pt :: ExPart{N}

Complement of a part of an `N`-element set
"""
function ~{N}(pt::ExPart{N})
    reinterpret(ExPart{N},
                (~reinterpret(UInt8, pt)) &
                (~zero(UInt8) >> (8 - N)))
end

"""
    ~rn :: ExRelation{N}

Complement of a relation on an `N`-element set
"""
function ~{N}(rn::ExRelation{N})
    reinterpret(ExRelation{N},
                (~reinterpret(UInt64, rn)) &
                (~zero(UInt64) >> (64 - N^2)))
end

"""
    (pt1 ⊆ pt2 :: ExPart{N}) :: Bool

"""
function ⊆{N}(pt1::ExPart{N}, pt2::ExPart{N})
    pt1 - pt2 == zero(ExPart{N})
end

"""
    (rn1 ⊆ rn2 :: ExRelation{N}) :: Bool

"""
function ⊆{N}(rn1::ExRelation{N}, rn2::ExRelation{N})
    rn1 - rn2 == zero(ExRelation{N})
end
