# FastEAR - Fast(er) Extraction of Alignment Regions

- Last modified: ons maj 19, 2021  05:21
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

*Update*: A script using bedtools for extraction is also provided (see [Requirements and
Installation](#requirements-and-installation)).

## Usage

    $ ./fastear_<version>.sh fasta.fas partitions.txt

Example:

    $ ./fastear_samtools-1.10.sh data/fasta.fas data/partitions.txt

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
Samtools v1.10 is available from, e.g., Ubuntu Linux repositories:

    $ sudo apt install samtools

The syntax for samtools faidx have changed between minor samtools versions, and
there are two versions of the fastear-script supplied; one for samtools v1.7, and
one for v1.10.

In addition, if one wishes to use the "bedtools"-version, then `bedtools` needs
to be installed (tested using v2.27). For example (on ubuntu):

    $ sudo apt install bedtools

Finally, put the fastear-script(s) in your PATH (e.g., `cp fastear_*.sh ~/bin/`).

## Timings

From a fasta file with 146 sequences, each with length 6,180,000 bp, we
extracted 4,818 alignments (on a GNU/Linux system with two Intel Xeon Silver
4214 CPU @ 2.20GHz, 48 cores in total):

#### Using GNU parallel

    #  fastear pyfaidx v.0.5.8 parallel
    $ time fastear_pyfaidx.sh data.fas partitions.txt
    real    0m47,499s
    user    16m44,924s
    sys     3m8,175s

    # fastear samtools faidx v.1.7 parallel
    $ time fastear_samtools-1.7.sh data.fas partitions.txt
    real    0m19,714s
    user    1m43,326s
    sys     1m18,667s

    # fastear samtools faidx v.1.10 parallel
    $ time fastear_samtools-1.10.sh data.fas partitions.txt
    real    0m20,172s
    user    1m31,063s
    sys     1m12,016s

    # fastear bamtools parallel
    $ time fastear_bedtools.sh data.fas partitions.txt
    real    0m19,784s
    user    1m3,445s
    sys     0m53,333s


#### Using a "while read"-loop over the partitions file

    #  fastear pyfaidx v.0.5.8 serial
    $ time fastear_pyfaidx.serial.sh data.fas partitions.txt
    real    11m16,616s
    user    9m50,814s
    sys     2m11,124s

    # fastear samtools faidx v.1.7 serial
    $ time fastear_samtools-1.7.serial.sh data.fas partitions.txt
    real    2m2,562s
    user    1m33,131s
    sys     0m53,938s

    # fastear samtools faidx v.1.10 serial
    $ time fastear_samtools-1.10.serial.sh data.fas partitions.txt
    real    1m47,825s
    user    1m18,883s
    sys     0m52,152s

## Disclaimer

Currently in beta version, with minimal error checking. *Caveat emptor!*

## License and Copyright

Copyright (C) 2020, 2021 Johan Nylander <johan.nylander\@nrm.se>.
Distributed under terms of the [MIT license](LICENSE).
