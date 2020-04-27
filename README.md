# EAR - Extract Alignment Regions

- Last modified: mån apr 27, 2020  12:46
- Sign: JN

## Description

Shell (bash) scripts for extracting regions from a fasta-formatted nucleotide
alignment based on the description of ranges in a [partitions
file](#example-partitions-file).

The scripts act as a wrapper for the main software that performs the
extraction: faidx. GNU parallel is used for doing the extraction in parallel.

The string in the first column of the partitions file will be used as the stem
of the output file name, and the suffix `.fas` will be added (for example:
`Apa.fas`). The output file will contain all fasta entries in the input fasta
file, but only with the sequence positions as specified in the partitions file.

Note that only the first string (without white-space characters!) in the fasta
headers will be used in the output.

Currently two versions of the script is provided, differing in which version of
faidx used (see [Requirements and
Installation](#requirements-and-installation)).

## Usage

    $ ./ear_<version>.sh fasta.fas partitions.txt

Example:

    $ ./ear_samtools-1.7.sh data/fasta.fas data/partitions.txt

## Example partitions file

    Apa = 1-100
    Bpa = 101-200
    Cpa = 201-300
    Dpa = 301-400
    Epa = 401-484

## Requirements and Installation

Make sure to install [GNU parallel](https://www.gnu.org/software/parallel/),
and faidx. For faidx, I tried both the python version, pyfaidx
([https://pypi.org/project/pyfaidx](https://pypi.org/project/pyfaidx)), and the
original version from samtools
([https://github.com/samtools/samtools](https://github.com/samtools/samtools)).
The syntax for samtools faidx have changed between minor samtools versions, and
there are two versions of the ear-script supplied; one for samtools v1.7, an
one for v1.10.

Finally, put the ear-script(s) in your PATH (e.g., `cp ear_*.sh ~/bin/`).

## Timings 

From a fasta file with 146 sequences, each with length 6,180,000 bp, we
extracted 4,818 alignments (on a GNU/Linux system with two Intel Xeon Silver
4214 CPU @ 2.20GHz, 48 cores in total):

    #  ear pyfaidx v.0.5.8
    $ time ear_pyfaidx.sh NT.fas NT_partitions.txt
    real    1m44,919s
    user    27m23,834s
    sys     39m20,250s

    # ear samtools faidx v.1.7
    $ time ear_samtools-1.7.sh NT.fas NT_partitions.txt
    real    1m12,592s
    user    8m24,538s
    sys     45m36,692s

## Disclaimer

Currently in beta version, with minimal error checking. *Caveat emptor!*

## License and Copyright

Copyright (C) 2020 Johan Nylander <johan.nylander\@nrm.se>.
Distributed under terms of the [MIT license](LICENSE).
