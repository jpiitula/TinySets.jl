"""
    ExPart{N}

A part of an `N`-element set

A part is a subset *as a subset*. The parts of a set form a Boolean
lattice.

"""
bitstype 8 ExPart{N}

### Get rid of this!
function ExPart(N::Int, data::UInt8)
    # check 0 <= N <= 8
    # check data < 2^N
    reinterpret(ExPart{N}, data)
end

"""
    ExRelation{N}

A relation on an `N`-element set

"""
bitstype 64 ExRelation{N}

