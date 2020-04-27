#!/bin/bash

# EAR - Extract Alignment Regions
# Last modified: mån apr 27, 2020  12:18
# Usage:
#    ./ear_samtools-1.10.sh fasta.fas partitions.txt
# Description:
#     Extract alignments regions defined in partitions.txt
#     to new files from fasta.fas.
# Example partitions file:
#     Apa = 1-100
#     Bpa = 101-200
#     Cpa = 201-300
# Requirements:
#     samtools (v1.10), and GNU parallel
# License and Copyright:
#     Copyright (C) 2020 Johan Nylander (nylander)
#     <johan.nylander@nrm.se>.
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

command -v samtools > /dev/null 2>&1 || { echo >&2 "Error: samtools not found."; exit 1; }

sversion=$(samtools --version | perl -ne 'print $1 if /^samtools\s+([\.\d]+)/')
if [ ! "${sversion}" == "1.10" ] ; then
    echo "Error: requires samtools v1.10"
    exit 1
fi

echo -n "Creating faidx index..."

samtools faidx "${fastafile}" &> "${fastafile}.faidx.log"

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

function do_the_faidx () {
    name=$1
    pos=$2
    fas=$3
    name=$(tr -d ' ' <<< "${name}")
    pos=$(tr -d ' ' <<< "${pos}")
    IFS=- read -a coords <<< "${pos}"
    start="${coords[0]}"
    stop="${coords[1]}"
    if [[ "${start}" -eq 1 ]] ; then
        start=$(( start - 1 ))
    fi
    newpos="${start}-${stop}"
    echo -e "Writing pos ${pos} to ${name}.fas";

    samtools faidx "${fas}" \
        -r <(grep '>' "${fas}" | sed -e 's/>//g' -e 's/ .*//' -e "s/$/:${newpos}/") | \
        sed -e "s/:${newpos}$//" > "${name}".fas
}

export -f do_the_faidx

parallel -a "${partfile}" --colsep '=' do_the_faidx {1} {2} "${fastafile}" 

rm "${fastafile}.fai"

exit 0

