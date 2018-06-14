#! /usr/bin/env Rscript

source("http://bioconductor.org/biocLite.R")
biocLite(c('seqinr','DECIPHER'))
options(BioC_mirror="http://mirrors.ustc.edu.cn/bioc/")
biocLite(c('SRAdb','GO.db', 'GeneOverlap'))
install.packages("DECIPHER_2.8.1.tar.gz",repos=NULL)