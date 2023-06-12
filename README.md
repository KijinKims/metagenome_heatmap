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

Some packages can be easily installed with `install_packages()` function. However, some packages should be installed with Bioconductor.

## How to use

The workflow consists of two parts: taxonomic classification and heatmap generation.

### Taxnomic classification

For the classification, Centrifuge needs the index built with virus sequences. You can [build on your own](https://ccb.jhu.edu/software/centrifuge/manual.shtml#database-download-and-index-building) or download the index [here](https://zenodo.org/record/7662919).

You can run the classification and parse the output with the command lines

```console
centrifuge -x [centrifuge_index_dir]/[centrifuge_index_name] -U [input_fastq] -S [centrifuge_result]
centrifuge-kreport -x [centrifuge_index_dir]/[centrifuge_index_name] [centrifuge_result] > [centrifuge_kreport_result]
python parse_kreport.py --input [centrifuge_kreport_result] --output [parsed_kreport] --taxid [taxid]
```

Note that the Centrifuge index is given in the form of `directory/name`. For example, if you downloaded the index from the  link provided above, it can be given as `centrifuge_viral_230213/abv`.

And the NCBI taxid of the virus family you want needs to be given. You can find it by browsing the page [Browse viral genomes by family](https://www.ncbi.nlm.nih.gov/genomes/GenomesGroup.cgi?taxid=10239&sort=taxonomy) at NCBI. For example, if you want to genearte the heatmap of hantaviridae Family, click the family name and `Taxonomy` button like the below screenshot.
![screenshot1](/screenshot/screenshot1.png)

Next, click the family name.
![screenshot2](/screenshot/screenshot2.png)

You can find the taxid of Hantaviridae.
![screenshot3](/screenshot/screenshot3.png)

If the virus family you want is not included in [RefSeq](https://www.ncbi.nlm.nih.gov/refseq/), it is likely that you get the empty result. The default value of [taxid] is `1980413`, which is the taxid of Hantaviridae.

Please iterate the above process for each fastq. Then, you might have several parsed kreport files in the end.

### Heatmap generation

The heatmap is generated with the R script `generate_heatmap.R`. It requires three positional arguments. 

1. The first is the parsed kreport results from the above classificaiton step joined with commas. For example, if you have three files `sample1.txt`, `sample2.txt`, and `sample3.txt`, the first argument should be `sample1.txt,sample2.txt,sample3.txt`. In-between space or file name including space is not allowed.

2. The second is the sample ids corresponding to each file. For example, you can set `sample1,sample2,sample3` for the above example input files.

3. Last is the output png file including the resulting heatmap. Only png is allowed unless you edit the code by yourself. For example, `output_heatmap.png` can be given.

The final example command line could be
```console
Rscript generate_heatmap.R sample1.txt,sample2.txt,sample3.txt sample1,sample2,sample3 output_heatmap.png
```

## Future direction
Row annotation color-coded by genus.