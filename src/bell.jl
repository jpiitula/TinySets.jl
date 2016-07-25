# Copyright 2016 Jussi Piitulainen; free under GPLv3+, no warranty

"""
    bellboxen(n; least = 1)

Distribute the `n` elements of a set to `M` blocks where `M` is a
random variable that makes all partitions equally probable. The number
of partitions of an `n`-element set is the `n`th Bell number.

Resulting block numbers are also mapped to `1:8` - there may be more
boxes than elements - so that they can be in the codomain of a tiny
epimap. The new names start from a least number and increase in the
order of appearance of new blocks.

The number of elements must be in `1:8`. A safe choice for the least
block number is the first element of the domain.

See Stam (1983) and Knuth (7.2.1.5) for the theory. Do not trust the
present implementation. The outcomes do not look too bad, do they?
"""

function bellboxen(n; least = 1)
    bell = (1, 2, 5, 15, 52, 203, 877, 4140)
    u = rand()
    m = 0
    F = 0.0
    while F < u
        m += 1
        F += m^n / factorial(m) / e / bell[n]
    end

    boxen = rand(1:m, n)

    seen = Dict{Int,Int}()
    for (k,b) in enumerate(boxen)
        haskey(seen, b) || (seen[b] = least ; least += 1)
        boxen[k] = seen[b]
    end

    boxen
end
