# Kraken2 pipeline

Pipeline for running Kraken2 from paired-end or single-end data.

The pipeline is designed to be run on High Performance Computing (HPC) systems using the Slurm Workload Manager. Tasks are parallelized thanks to the Nextflow workflow system and the pipeline uses Docker containers to enhance reproducibility and portability.

/// ---------------------------------------- ///

## Overview:

### GENERATEKRAKEN2DB workflow

Run this workflow by selecting the 'prep_db' profile (see 'RUN COMMAND' section below).

* Kraken2 database generation (bacteria, fungi, viral, Homo sapiens, and EuPathDB46 genomes)

### KRAKEN2 workflow

Run this workflow by selecting the 'kraken2' profile (see 'RUN COMMAND' section below).

* Reads trimming and QC with TrimGalore

* Removing contaminants (e.g. human reads)

* Kraken2

/// ---------------------------------------- ///

## INPUT:

The kraken2 workflow reads samples' info from a tab-delimited file.
The file has the following columns:

* **sample**: unique sample identifier

* **fastq_1**: full path to fastq mate 1

* **fastq_2**: full path to fastq mate 2 (use "mock.fastq", unquoted, if single-end)

/// ---------------------------------------- ///

## OUTPUTS:

### GENERATEKRAKEN2DB workflow

A folder named "standard_plus_eupath46" is created by default in the project directory.

### KRAKEN2 workflow

All outputs are stored in the following subdirectories, within the project directory.

<pre>
<b>project_dir</b>
  │
  ├── <b>cleaned_reads</b>
  │
  ├── <b>cleaning_stats</b>
  │
  ├── <b>fastqc_reports</b>
  │
  ├── <b>k2_reports</b>
  │
  ├── <b>k2_outputs</b>
  │
  └── <b>trimmming_reports</b>
</pre>

/// ---------------------------------------- ///

## RUN COMMAND:

```
nextflow run main.nf -profile [PROFILES] [VARIABLES]
```

### PROFILES:

* **standard**: runs the pipeline using Docker

* **docker**: runs the pipeline using Docker

* **podman**: runs the pipeline using Podman

* **singularity**: runs the pipeline using Singularity

* **prep_db**: runs the GENERATEKRAKEN2DB workflow

* **kraken2**: runs the KRAKEN2 workflow

### VARIABLES:

* **reads_manifest_path**: full path to reads manifest

* **kraken_database_path**: full path to the Kraken2 database

* **remove_contaminants**: whether to remove reads mapping to a contaminant species (e.g. human)

* **contaminant_fasta**: path to fasta file for the contaminant species

* **bwa_index_dir**: path to directory containing the BWA index for the contaminant species

* **bwa_index_prefix**: prefix of BWA index file

/// ---------------------------------------- ///

## DEPENDENCIES:

* Nextflow 23.10.1+

* Container platform, one of
    * Docker 20.10.21+
    * Podman
    * Singularity 3.8.5+

* Slurm
