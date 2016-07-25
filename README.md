# TinySets

This is, or will be, an implementation of *tiny sets* (defined as
parts aka subsets of a given set of eight points) together with *tiny
maps* (functions between tiny sets) and *tiny relations* (parts of
binary products of tiny sets) between them -- typed, so that each map
and relation has a specific tiny set as domain and a specific tiny set
as codomain.

The module is developed as a learning experience. Initial topics to
learn, apart from the Julia language, include some of the lesser
topics in ETCS (the set theory) and basic combinatorics. Eventual
further topics might include something on finite topological spaces.

However, while the /author/ has already learned a lot and expects to
learn more still, there is /absolutely no warranty/ that any
beneficial effects occur for anybody else. That would be nice but
nothing more.

The author has no intention to expand to bigger sets. That would be a
different project. Note that there are millions of functions and
billions of relations at hand even for the relatively small number of
256 tiny sets.

## Contents

* Boolean lattice operations, inclusion (for sets, for relations,
  for monomaps with the same codomain)
* Composition of maps, composition of relations (if compatible)
* Inverse of a map (if invertible), opposite relation
* Identity map of a set, graph of a map as a relation
* Image of a map, preimage of a set along a map (as sets)
* Product of sets (as a relation)
* Random set, map, monomap, part, epimap, partition
* Random relation, random equivalence relation
* Each set, map, and so on (generated on demand)

* Todo: left and right inverses (if any) of a map
* Todo: partial order relations
* Todo: something about partitions

## News

* Initial draft has been basically re-drafted and much expanded (early
  relations were not really typed, and there were no functions at all)

## "Property"

Copyright 2016 Jussi Piitulainen

The code can be freely shared (copied, studied, modified, distributed)
under the terms of the GNU General Public License, either version 3 or
a later version, as published by the Free Software Foundation.
