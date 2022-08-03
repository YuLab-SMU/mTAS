# mTAS
A snakemake workflow for comprehensive analysis of toxin-antitoxin systems

* [Introduction](#introduction)
* [Version](#version)
* [Requirement](#requirement)
* [Installation](#installation)
* [Usage](#usage)

## Introduction 
The mTAS is a pipeline for toxin-antitoxin (TA) analysis. Using a curated reference database, mTAS conducts homology-based strategy to identify TA gene hits and produce reliable, deduplicated homologs. The mTAS accecpts both genome assemblies and high-throughput sequencing data and produce a summary of grouped by TA families. 


#### Database description
The curated database consis of references from different sources in cluding TADB2, T1TAdb, TASmania and some sequences curated from previous studies. These reference records covers type I ~ VIII TA classes 

## Version
+ 0.1.4


## Requirement
+ fastp >= 0.20
+ histat 2.1.0
+ Blast+ >= 2.10.1
+ (optional) hs-blastn 2.0.0 
+ (optional) diamond v2.0.6.144 
+ (optional) prodigal
+ viralVerify

+ Python 3 (tested in 3.8.3 / 3.6.9 )
+ Snakemake >= 7.8.0 
+ Pandas >= 1.3.4 


## Installation
```
git clone https://github.com/YuLab-SMU/mTAS.git
```


## Usage
Given a folder containin input fasta/fastq files, run the wrapper script run_pipe.sh under the root path.
```
ind=/PATH/TO/FASTQ
oud=/PATH/FOR/STORING/OUTPUT
bash run_pipe.sh $ind $oud
```

#### Advantage usage:
By default, parameters were stored in the `config/params.yaml`, these could be adjusted based on your needs. Another way is modifying the smk files stored in the `rule` direcotry. 

The `config/config.yaml` contains prefined folders for storing intemediate files. You may also modified for your convenience.

