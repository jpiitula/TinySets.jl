"""
    TinyPart{N}

A part of an `N`-element set

A part is a subset *as a subset*. The parts of a set form a Boolean
lattice.

"""
bitstype 8 TinyPart{N}

### Get rid of this!
function TinyPart(N::Int, data::UInt8)
    # check 0 <= N <= 8
    # check data < 2^N
    reinterpret(TinyPart{N}, data)
end

"""
    TinyRelation{N}

A relation on an `N`-element set

"""
bitstype 64 TinyRelation{N}

