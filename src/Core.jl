# Included in TinySets.jl

# Parsed and printed as bit patterns.

"""
    Pt"1011" :: TinyPart{4}

A part of an `N`-element set

`Pt"1011"` stands for {1,3,4} as a part of the set {1,2,3,4}.

"""
macro Pt_str(s)
    # e.g. Pt"101" means {1, 3} as a part of {1,2,3}
    N = length(s)
    if N == 0
        TinyPart(0, 0x0)
    else
        TinyPart(N, parse(UInt8, s, 2))
    end
end

function Base.show{N}(io::Base.IO, pt::TinyPart{N})
    bs = bits(reinterpret(UInt8, pt))[(end - N + 1):end]
    println(io, "Tiny $(N)-Part")
    println(io, "  $(join(bs, ' '))")
end

function Base.showcompact{N}(io::Base.IO, pt::TinyPart{N})
    bs = bits(reinterpret(UInt8, pt))[(end - N + 1):end]
    print(io, "Pt\"$bs\"")
end

"""
    Rn"100 010 011" :: TinyRelation{3}

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
    reinterpret(TinyRelation{N}, rep)
end

function Base.show{N}(io::Base.IO, rn::TinyRelation{N})
    rep = bits(reinterpret(UInt64, rn))
    println(io, "Tiny $(N)-Relation")
    if N > 0
        for t in range(N^2, -N, N)
            bs = join(rep[(end - t + 1):(end - t + N)], ' ')
            println(io, "  $bs")
        end
    end
end

function Base.showcompact{N}(io::Base.IO, rn::TinyRelation{N})
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
    length(pt::TinyPart{N})
"""
length{N}(pt::TinyPart{N}) = count_ones(reinterpret(UInt8, pt))

"""
    length(rn::TinyRelation{N})
"""
length{N}(rn::TinyRelation{N}) = count_ones(reinterpret(UInt64, rn))

"""
    length(TinyPart{N}) == 2^N

The number of parts of an `N`-element set.
"""
length{N}(::Type{TinyPart{N}}) = 2^N

"""
    length(TinyRelation{N}) == 2^(N^2)

The number of relation on an `N`-element set.
"""
length{N}(::Type{TinyRelation{N}}) = 2^(N^2)

"""
    (pt :: TinyPart{N})[k] :: Int

Indicate membership of `k` in `pt` by `1` or `0`

See also `k ∈ pt`.

"""
function getindex{N}(pt::TinyPart{N}, k::Int)
    # check 1 <= k <= N
    Int((reinterpret(UInt8, pt) >> (N - k)) & one(UInt8))
end

"""
    (rn :: TinyRelation{N})[r,k] :: Int

Indicate membership of `(r,k)` in `rn` by `1` or `0`.

See also `(r,k) ∈ rn`.

"""
function getindex{N}(rn::TinyRelation{N}, r::Int, k::Int)
    rep = reinterpret(UInt64, rn)
    Int(0x1 & (rep >> (N * (N - r) + (N - k))))
end

function getindex{N}(rn::TinyRelation{N}, r::Int, k::Colon)
    rep = reinterpret(UInt64, rn)
    reinterpret(TinyPart{N},
                UInt8((one(UInt64) << N - 1) &
                      (rep >> (N * (N - r)))))
end

function getindex{N}(rn::TinyRelation{N}, r::Colon, k::Int)
    function im(r)
        ((r,k) ∈ rn) ? point(TinyPart{N}, r) : zero(TinyPart{N})
    end
    reduce(∪, zero(TinyPart{N}), map(im, 1:N))
end

### Creation methods

function point{N}(::Type{TinyPart{N}}, k::Int)
    reinterpret(TinyPart{N},
                one(UInt8) << (N - k))
end

function point{N}(pt::TinyPart{N}, k::Int)
    point(typeof(pt), k)
end

function point{N}(::Type{TinyRelation{N}}, r::Int, k::Int)
    reinterpret(TinyRelation{N},
                one(UInt64) << (N * (N - r) + (N - k)))
end

function point{N}(rn::TinyRelation{N}, r::Int, k::Int)
    point(typeof(rn), r, k)
end

function times{N}(r::Int, pt::TinyPart{N})
    reinterpret(TinyRelation{N},
                UInt64(reinterpret(UInt8, pt)) << (N * (N - r)))
end
×{N}(r::Int, pt::TinyPart{N}) = times(r, pt)

function times{N}(pt::TinyPart{N}, k::Int)
    im(r) = point(TinyRelation{N}, r, k)
    reduce(∪, zero(TinyRelation{N}), map(im, each(Int, pt)))
end
×{N}(pt::TinyPart{N}, k::Int) = times(pt, k)

function times{N}(pt1::TinyPart{N}, pt2::TinyPart{N})
    im(r) = r × pt2
    reduce(∪, zero(TinyRelation{N}), map(im, each(Int, pt1)))
end
×{N}(pt1::TinyPart{N}, pt2::TinyPart{N}) = times(pt1, pt2)

### Membership tests.

"""
    (k ∈ pt :: TinyPart{N}) :: Bool

`True` if `k` is in the part `pt` of an `N`-element set
"""
function ∈{N}(k::Int, pt::TinyPart{N})
    (reinterpret(UInt8, pt) >> (N - k)) & one(UInt8) == one(UInt8)
end

function ∈{N}(rk::Tuple{Int,Int}, rn::TinyRelation{N})
    r, k = rk
    rep = reinterpret(UInt64, rn)
    (rep >> (N * (N - r) + (N - k))) & one(UInt64) == one(UInt64)
end

### Random parts and relations

"""
    randp(n::Int) :: TinyPart{n}

Return a random part of an `n`-element set
"""
function randp(n::Int)
    reinterpret(TinyPart{n},
                rand(zero(UInt8):(one(UInt8) << n - one(UInt8))))
end

"""
    randp(pt::TinyPart{N}) :: TinyPart{N}

Return a random part of an `N`-element set
"""
randp{N}(::TinyPart{N}) = randp(N)

"""
    randp(rn::TinyRelation{N}) :: TinyPart{N}

Return a random part of an `N`-element set
"""
randp{N}(::TinyRelation{N}) = randp(N)

"""
    randr(n::Int) :: TinyRelation{n}

Return a random relation on an `n`-element set
"""
function randr(n::Int)
    reinterpret(TinyRelation{n},
                rand(zero(UInt64):(one(UInt64) << n^2 - one(UInt64))))
end

"""
    randr(pt::TinyPart{N}) :: TinyRelation{N}

Return a random relation on an `N`-element set
"""
randr{N}(::TinyPart{N}) = randr(N)

"""
    randr(rn::TinyRelation{N}) :: TinyRelation{N}

Return a random relation on an `N`-element set
"""
randr{N}(::TinyRelation{N}) = randr(N)


### Composition and related operations.

"""
    (rn1 ∘ rn2) :: TinyRelation{N}

Composition of relations on an `N`-element set

"""
function ∘{N}(rn1::TinyRelation{N}, rn2::TinyRelation{N})
    function im(r)
        pt = rn1[r,:] ∘ rn2
        reinterpret(TinyRelation{N},
                    UInt64(reinterpret(UInt8, pt)) << ((N - r) * N))
    end
    reduce(∪, zero(TinyRelation{N}), map(im, 1:N))
end

"""
    (pt ∘ rn) :: TinyPart{N}

Image of a part of an `N`-element set along a relation

"""
function ∘{N}(pt::TinyPart{N}, rn::TinyRelation{N})
    im(k) = rn[k,:]
    reduce(∪, zero(TinyPart{N}), map(im, each(Int, pt)))
end

"""
    (rn ∘ pt) :: TinyPart{N}

Pre-image of a part of an `N`-element set along a relation

"""
function ∘{N}(rn::TinyRelation{N}, pt::TinyPart{N})
    im(r) = rn[:,r]
    reduce(∪, zero(TinyPart{N}), map(im, each(Int, pt)))
end

"""
    R^n :: TinyRelation{N}
"""
function Base.(:^){N}(m::TinyRelation{N}, n::Int)
    # assert n >= 0
    it(k) = m
    reduce(∘, eye(typeof(m)), map(it, 1:n))
end

"""
    rn' :: TinyRelation{N}
    ctranspose(rn)

Opposite relation on an `N`-element set
"""
function Base.ctranspose{N}(rn::TinyRelation{N})
    T = typeof(rn)
    im(k) = times(k, rn[:,k])
    reduce(∪, zero(T), map(im, 1:N))
end

# diag : diagr cf. diag : diagm for matrices in Julia Base

"""
    diagr(pt::TinyPart{N}) :: TinyRelation{N}

Represent the part as a diagonal relation
"""
function diagr{N}(pt::TinyPart{N})
    im(k) = ((k ∈ pt)
             ? reinterpret(TinyRelation{N},
                           one(UInt64) << (N * (N - k) + (N - k)))
             : zero(TinyRelation{N}))
    reduce(∪, zero(TinyRelation{N}), map(im, 1:N))
end

"""
    diag(rn::TinyRelation{N}) :: TinyPart{N}

Extract the diagonal of the relation as a part

Use `diagr` to construct a diagonal relation.
"""
function diag{N}(rn::TinyRelation{N})
    im(k) = (((k,k) ∈ rn)
             ? reinterpret(TinyPart{N},
                           one(UInt8) << (N - k))
             : zero(TinyPart{N}))
    reduce(∪, zero(TinyPart{N}), map(im, 1:N))
end

Δ{N}(pt::TinyPart{N}) = diagr(pt)
Δ{N}(rn::TinyRelation{N}) = diag(rn)

"""
    eye(pt::TinyPart{N}) :: TinyRelation{N}

Identity relation
"""
eye{N}(::Type{TinyPart{N}}) = diagr(one(TinyPart{N}))
eye{N}(::Type{TinyRelation{N}}) = eye(TinyPart{N})
eye{N}(pt::TinyPart{N}) = eye(TinyPart{N})
eye{N}(rn::TinyRelation{N}) = eye(TinyRelation{N})

# Parts of a set form a Boolean lattice.
# Relations on a set form a Boolean lattice.

"""
    zero(TinyPart{N})

Empty part
"""
function zero{N}(::Type{TinyPart{N}})
    reinterpret(TinyPart{N}, zero(UInt8))
end

"""
    zero(pt::TinyPart{N})
"""
zero{N}(pt::TinyPart{N}) = zero(typeof(pt))

"""
    zero(TinyRelation{N})

Empty relation
"""
function zero{N}(::Type{TinyRelation{N}})
    reinterpret(TinyRelation{N}, zero(UInt64))
end

"""
    zero(rn::TinyRelation{N})
"""
zero{N}(rn::TinyRelation{N}) = zero(typeof(rn))

"""
    one(TinyPart{N})

"Full" part with all `N` elements as members
"""
function one{N}(::Type{TinyPart{N}})
    reinterpret(TinyPart{N}, ~zero(UInt8) >> (8 - N))
end

one{N}(pt::TinyPart{N}) = one(typeof(pt))

function one{N}(::Type{TinyRelation{N}})
    reinterpret(TinyRelation{N}, ~zero(UInt64) >> (64 - N * N))
end

one{N}(rn::TinyRelation{N}) = one(typeof(rn))

"""
    pt1 ∪ pt2 :: TinyPart{N}

Union of parts of an `N`-element set
"""
function ∪{N}(pt1::TinyPart{N}, pt2::TinyPart{N})
    reinterpret(TinyPart{N},
                reinterpret(UInt8, pt1) |
                reinterpret(UInt8, pt2))
end

"""
    rn1 ∪ rn2 :: TinyRelation{N}

Union of relations on an `N`-element set
"""
function ∪{N}(rn1::TinyRelation{N}, rn2::TinyRelation{N})
    reinterpret(TinyRelation{N},
                reinterpret(UInt64, rn1) |
                reinterpret(UInt64, rn2))
end

"""
    pt1 ∩ p:: TinyPart{N}

Intersection of parts of an `N`-element set
"""
function ∩{N}(pt1::TinyPart{N}, pt2::TinyPart{N})
    reinterpret(TinyPart{N},
                reinterpret(UInt8, pt1) &
                reinterpret(UInt8, pt2))
end

"""
    pt1 ∩ pt2 :: TinyRelation{N}

Intersection of relations on an `N`-element set
"""
function ∩{N}(rn1::TinyRelation{N}, rn2::TinyRelation{N})
    reinterpret(TinyRelation{N},
                reinterpret(UInt64, rn1) &
                reinterpret(UInt64, rn2))
end

function Base.(:-){N}(pt1::TinyPart{N}, pt2::TinyPart{N})
    reinterpret(TinyPart{N},
                reinterpret(UInt8, pt1) &
                ~reinterpret(UInt8, pt2))
end

function Base.(:-){N}(rn1::TinyRelation{N}, rn2::TinyRelation{N})
    reinterpret(TinyRelation{N},
                reinterpret(UInt64, rn1) &
                ~reinterpret(UInt64, rn2))
end

"""
    ~pt :: TinyPart{N}

Complement of a part of an `N`-element set
"""
function ~{N}(pt::TinyPart{N})
    reinterpret(TinyPart{N},
                (~reinterpret(UInt8, pt)) &
                (~zero(UInt8) >> (8 - N)))
end

"""
    ~rn :: TinyRelation{N}

Complement of a relation on an `N`-element set
"""
function ~{N}(rn::TinyRelation{N})
    reinterpret(TinyRelation{N},
                (~reinterpret(UInt64, rn)) &
                (~zero(UInt64) >> (64 - N^2)))
end

"""
    (pt1 ⊆ pt2 :: TinyPart{N}) :: Bool

"""
function ⊆{N}(pt1::TinyPart{N}, pt2::TinyPart{N})
    pt1 - pt2 == zero(TinyPart{N})
end

"""
    (rn1 ⊆ rn2 :: TinyRelation{N}) :: Bool

"""
function ⊆{N}(rn1::TinyRelation{N}, rn2::TinyRelation{N})
    rn1 - rn2 == zero(TinyRelation{N})
end
