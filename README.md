#DamID Sequencing Analysis and LADetector Algorithm for LAD Segmentation
For a detailed description of the DamID-sequencing protocol and the benchmarking of our program, please refer to:
*“LADetector: a rapid, large-domain calling algorithm that allows for accurate identification of edges and dips with both ChIP and DamID technologies“* Wong and Luperchio et al.

*If you use our program to analyze your data in a published work, please cite the above paper in your publication.*

For questions about usage, please email Xianrong Wong: xwong2@jhu.edu, Teresa Luperchio: trl@jhmi.edu, or Karen Reddy: kreddy4@jhmi.edu.

## Introduction

DNA Adenine Methyltransferase Identification, DamID, has been commonly used to probe lamina chromatin interactions in cells. The detailed description of the DamID protocol is found in *Vogel et al, Detection of in vivo protein-DNA interactions using DamID in mammalian cells. Nature Protocols 2007*. For a detailed description of the adaptation for sequencing, please refer to our paper. In brief, the end point of DamID amplification is a pool of DNA amplicons flanked by DamID adapters/primers which range typically between 200bp – 3kb. To obtain a library size of between 100-300bp for efficient flow cell clustering, the DamID amplicons are randomized by inter-fragment ligation followed by sonication, to prevent possible preferential loss of smaller DNA fragments by straight up sonication of the DamID amplicons. This, however, will generate DNA fragments with some probability of harboring DamID primer sequences which have to be bioinformatically removed prior to mapping to a reference index.

This program can be divided into three parts; **mapping**, **normalization** and **LAD detection**. The first part, pre-normalization mapping, deals with the removal of primer sequences and mapping of the reads to a reference genome. This is followed by counting the number of reads that have been mapped to each genomic bin, genome wide. The second part of the program normalizes the counts in each bin to the sequencing depth of both the experimental sample and the control sample. The normalized experimental scores are then further normalized to the control sample scores to yield genome wide log2-ratios. Part three of the program uses the LADetector version 2 algorithm to extract genomic intervals for LADs and DIPs from the log2-ratios (version 1 was published and provided in *Harr JC, Luperchio TR, Wong X, Cohen E, Wheelan SJ, Reddy KL “Directed targeting of chromatin to the nuclear lamina is mediated by chromatin state and A-type lamins”. JCB 2015 January 5*).

## Command line tool
### 1. Installation

TBD, currently installation is possible by cloning the git directory and running conda build, but shortly we will provide instructions for installation via conda.

### 2. Usage

After installation, usage is via the command 

> ladetector -d (list of dam fastq files) -l (list of lamnb files) -sn (sample name)

-o is an optional flag if you would like to output the files somewhere besides the ladetector working directory. 

Either in the working directory or in the output directory, you will have a large collection of files. The files you are interested in will sample_name.LADs, sample_name.DIPs, and potentially sample_name.normalized. sample_name.LADs and sample_name.DIPs are in BED4 format, and contain respectively regions that are called as LADs and as DIPs. sample_name.normalized is in bedgraph format and contains log2 ratios of lamnb to dam signal. 
