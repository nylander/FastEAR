#!/bin/bash

# FastEAR - Fast(er) Extraction of Alignment Regions
# Last modified: tis feb 22, 2022  06:15
# Usage:
#    ./fastear_samtools-1.10.sh fasta.fas partitions.txt
# Description:
#     Extract alignments regions defined in partitions.txt
#     to new files from fasta.fas.
# Example partitions file:
#     Apa = 1-100
#     Bpa = 101-200
#     Cpa = 201-300
# Requirements:
#     samtools (v1.10 or above), and GNU parallel
# License and Copyright:
#     Copyright (C) 2020-2022 Johan Nylander
#     <johan.nylander\@nrm.se>.
#     Distributed under terms of the MIT license. 

minversion="1.10"

if [[ -n "$1" && -n "$2" ]] ; then
    fastafile="$1"
    partfile="$2"
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
#sversion=$(samtools --version | sed -n 's/samtools \(.*\)$/\1/p')

function version_ge() {
    test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1";
}

if ! version_ge "$sversion" "$minversion" ; then
    echo "Error: requires samtools v$minversion or above"
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
    if [[ "${start}" -eq 1 ]] ; then
        start=$(( start - 1 ))
    fi
    newpos="${start}-${stop}"
    echo -e "Writing pos ${pos} to ${name}.fas";

    samtools faidx "${fas}" \
        -r <(sed -e "s/ /:""${newpos}""\n/g" <<< "${headers}" | sed '/^$/d') | \
        sed -e "s/:${newpos}$//" > "${name}".fas
}

export -f do_the_faidx

parallel -a "${partfile}" --colsep '=' do_the_faidx "{1}" "{2}" "${fastafile}" 

rm "${fastafile}.fai"

exit 0

