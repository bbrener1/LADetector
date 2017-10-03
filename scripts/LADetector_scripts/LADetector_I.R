
#source("https://bioconductor.org/biocLite.R")
#biocLite("DNAcopy")
library(DNAcopy)


args <- commandArgs(TRUE)


complete_tab <- read.table(args[1], header=F) # unncessary, for cosmetics if running at the same time as above. If running separately, read in your normalized file here.
samples <- names(complete_tab)
for (i in 4:length(samples))
{
  copynum <- CNA(complete_tab[,i], complete_tab[,1], complete_tab[,2], data.type="logratio");
  smooth_cn <- smooth.CNA(copynum)
  ssc <- segment(smooth_cn, alpha=0.001)
  write(t(ssc$output), sep="\t", ncolumns=6, file=args[2])
}
