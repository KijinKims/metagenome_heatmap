# Metagenome Heatmap

This is a simple workflow to generate heatmap of taxonomic classificaiton of Nanopore reads to RefSeq viral sequences.
It employs [Centrifuge](https://ccb.jhu.edu/software/centrifuge/), a taxonomic classification tool, and create the heatmap using its output with [ComplexHeatmap](https://github.com/jokergoo/ComplexHeatmap) R package.

## Installation

You can install the required programs using [Anaconda](https://www.anaconda.com/).

```console
conda create -n [env_name] pandas bioconda::centrifuge
conda activate [env_name]
```

And you need to install following R packages.

- dplyr
- readr
- ComplexHeatmap
- GetoptLong
- circlize
- randomcoloR
- argparse

Some packages can be easily installed with `install_packages()` function. However, some packages should be installed with Bioconductor.

## How to use

The workflow consists of two parts: taxonomic classification and heatmap generation.

### Taxnomic classification

For the classification, Centrifuge needs the index built with virus sequences. You can [build on your own](https://ccb.jhu.edu/software/centrifuge/manual.shtml#database-download-and-index-building) or download the index [here](https://zenodo.org/record/7662919).

You can run the classification and parse the output with the command lines

```console
centrifuge -x [centrifuge_index_dir]/[centrifuge_index_name] -U [input_fastq] -S [centrifuge_result]
centrifuge-kreport -x [centrifuge_index_dir]/[centrifuge_index_name] [centrifuge_result] > [centrifuge_kreport_result]
python parse_kreport.py --input [centrifuge_kreport_result] --output [parsed_kreport]
```

Note that the Centrifuge index is given in the form of `directory/name`. For example, if you downloaded the index from the  link provided above, it can be given as `centrifuge_viral_230213/abv`.

Please iterate the above process for each fastq. Then, you might have several parsed kreport files in the end.

### Heatmap generation

The heatmap is generated with the R script `generate_heatmap.R`.

```console
generate_heatmap.R [-h] [-f file1.txt,file2.txt,file3.txt]
                          [-n sample1,sample2,sample3] [-m metadata.csv]
                          [-o output.png] [--min-read-count MIN_READ_COUNT] [-e export.csv]

options:
  -h, --help            show this help message and exit
  -f file1.txt,file2.txt,file3.txt, --files file1.txt,file2.txt,file3.txt
                        Input file as comma-delimited list.
  -n sample1,sample2,sample3, --names sample1,sample2,sample3
                        Sample name as comma-delimited list. Each corresponds
                        to the input file standing at the same position.
  -m metadata.csv, --metadata metadata.csv
                        Metadata as in csv consisting of three columns:
                        Sample, Host species, Health condition. Health
                        condition should be either Healthy or Unhealthy.
  -o output.png, --output output.png
                        Output file path. It should be with .png.
  --min-read-count MIN_READ_COUNT
                        Minimum read count to be considered.
  -e export.csv --export-raw export.csv
                        File path to which the raw read count matrix is exported.
```

Below is the example command line.
```console
Rscript generate_heatmap.R -f file1.txt,file2.txt,file3.txt -n sample1,sample2,sample3 -o output.png --min-read-count 5 -e export.csv
```

Below is the example output
![output](/screenshot/example_output.png)
