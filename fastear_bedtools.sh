#!/bin/bash

# FastEAR - Fast(er) Extraction of Alignment Regions
# Last modified: ons maj 19, 2021  02:15
# Usage:
#    ./fastear_bedtools.sh fasta.fas partitions.txt
# Description:
#     Extract alignments regions defined in partitions.txt
#     to new files from fasta.fas.
# Example partitions file:
#     Apa = 1-100
#     Bpa = 101-200
#     Cpa = 201-300
# Requirements:
#     bedtools (v2.27.1), and GNU parallel
# Notes:
#     The script will only use the first string
#     (no white space) as output header.
# License and Copyright:
#     Copyright (C) 2021 Johan Nylander
#     <johan.nylander\@nrm.se>.
#     Distributed under terms of the MIT license. 

if [[ -n "$1" && -n "$2" ]] ; then
    fastafile=$1
    partfile=$2
    if [ ! -e "${fastafile}" ]; then
        echo "Error: can not find ${fastafile}"
        exit 1
    fi
    if [ ! -e "${partfile}" ]; then
        echo "Error: can not find ${partfile}"
        exit 1
    fi
else
    echo "Usage: $0 fastafile partitionsfile"
    exit 1
fi

command -v bedtools > /dev/null 2>&1 || { echo >&2 "Error: bedtools not found."; exit 1; }

headers=$(grep '>' "${fastafile}" | sed -e 's/>//g' -e 's/ .*//' | tr '\n' ' ')
export headers

if [ ! -e "${fastafile}.fai" ]; then
    createdindexfile=1
fi

function do_the_bedtools () {
    name=$1
    pos=$2
    fas=$3
    name=$(tr -d ' ' <<< "${name}")
    pos=$(tr -d ' ' <<< "${pos}")
    IFS=- read -a coords <<< "${pos}"
    start=$(( "${coords[0]}" - 1 ))
    stop="${coords[1]}"
    echo -e "Writing pos ${pos} to ${name}.fas";
    bedtools getfasta -fi "${fas}" -fo "${name}".fas -name \
        -bed <(for h in ${headers[@]}; do echo -e "${h}\t${start}\t${stop}\t${h}"; done) > "${name}.fas" 2> /dev/null
}
export -f do_the_bedtools

parallel -a "${partfile}" --colsep '=' do_the_bedtools {1} {2} "${fastafile}" 

if [ "${createdindexfile}"==1 ] &&  [ -e "${fastafile}.fai" ]; then
    rm "${fastafile}.fai"
fi

exit 0

