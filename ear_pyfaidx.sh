#!/bin/bash

# EAR - Axtract Alignment Regions
# Last modified: tis apr 28, 2020  01:16
# Usage:
#    ./ear_pyfaidx.sh fasta.fas partitions.txt
# Description:
#     Extract alignments regions defined in partitions.txt
#     to new files from fasta.fas.
# Example partitions.txt:
#     Apa = 1-100
#     Bpa = 101-200
#     Cpa = 201-300
# Requirements:
#     faidx (pyfaidx), and GNU parallel
# License and Copyright:
#     Copyright (C) 2020 Johan Nylander
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

command -v faidx > /dev/null 2>&1 || { echo >&2 "Error: faidx not found."; exit 1; }

echo -n "Creating faidx index..."

faidx --no-output "${fastafile}"  > "${fastafile}.faidx.log" 2>&1

if [ $? -eq 0 ] ; then
    echo " done"
    rm "${fastafile}.faidx.log"
else
    echo ""
    echo "Error: Could not create faidx index:"
    cat "${fastafile}.faidx.log"
    rm "${fastafile}.faidx.log"
    exit 1
fi

headers=$(grep '>' "${fastafile}" | sed -e 's/>//g' -e 's/ .*//' | tr '\n' ' ')
export headers

function do_the_faidx () {
    name=$1
    pos=$2
    fas=$3
    name=$(tr -d ' ' <<< "${name}")
    pos=$(tr -d ' ' <<< "${pos}")
    IFS=- read -a coords <<< "${pos}"
    start="${coords[0]}"
    stop="${coords[1]}"
    start=$(( start - 1 ))
    echo -e "Writing pos ${pos} to ${name}.fas";
    faidx \
        --no-coords \
        --bed <(sed -e "s/ / "${start}" "${stop}"\n/g" <<< "${headers}" | sed '/^$/d') \
        -o "${name}".fas \
        "${fas}"
}
export -f do_the_faidx

parallel -a "${partfile}" --colsep '=' do_the_faidx {1} {2} "${fastafile}" 

rm "${fastafile}.fai"

exit 0

