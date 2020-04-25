# EAR - Extract Alignment Regions

- Last modified: Sun Apr 26, 2020  12:50AM
- Sign: JN

## Description

Shell (bash) scripts for extracting regions from a fasta-formatted nucleotide
alignment based on the description of ranges in a [partitions
file](#example-partitions-file). The string in the first column of the
partitions file will be used as the stem of the output file name, and the
suffix `.fas` will be added. For example: `Apa.fas`. The output file will
contain all fasta entries in the input fasta file, but only with sequence
positions as specified after the equal sign in the partitions file.

The scripts act as a wrapper for the main software that performs the
extraction: faidx. GNU parallel is used for doing the extraction in parallel.

Currently two versions of the script is provied, differing in which version of
faidx that is used (see [Requirements and
Installation](#requirements-and-installation)).

## Usage

    $ ./ear_pyfaidx.sh data/fasta.fas data/partitions.txt
    $ ./ear_samtools.sh data/fasta.fas data/partitions.txt

## Example partitions file

    Apa = 1-100
    Bpa = 101-200
    Cpa = 201-300
    Dpa = 301-400
    Epa = 401-484

The string in the first column will be used as the stem of the file name,
and the suffix `.fas` will be added. For example: `Apa.fas`.

## Requirements and Installation

Make sure to install [GNU parallel](https://www.gnu.org/software/parallel/),
and faidx. For faidx, I tried both the python version, pyfaidx
([https://pypi.org/project/pyfaidx](https://pypi.org/project/pyfaidx)), and the
original version from samtools ([http://www.htslib.org/](http://www.htslib.org/)).
Specifically, I used samtools v.1.7 from Ubuntu 18.04 repositories (note that
the syntax varies sometimes extensively between samtools versions).
Finally, put the ear-script(s) in your PATH (e.g., `cp ear_samtools.sh ~/bin/`).

## Timings 

From a fasta file with 146 sequences, each with length 6,180,000 bp, we
extracted 4,818 alignments (on a GNU/Linux system with two Intel Xeon Silver
4214 CPU @ 2.20GHz, 48 cores in total):

    # pyfaidx v.0.5.8
    $ time ear_pyfaidx.sh NT.fas NT_partitions.txt
    real    1m44,919s
    user    27m23,834s
    sys     39m20,250s

    # samtools faidx v.1.7
    $ time ear_samtools.sh NT.fas NT_partitions.txt
    real    1m12,592s
    user    8m24,538s
    sys     45m36,692s

Even with repeated runs, samtools seems to be more efficient.

### License and Copyright

Copyright (C) 2020 Johan Nylander <johan.nylander\@nrm.se>.
Distributed under terms of the [MIT license](LICENSE).
