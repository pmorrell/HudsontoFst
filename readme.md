This Perl script converts a Hudson table file to input for the R package heirfstat.

The script converts SNP genotyping data in two line format, a format used for Richard Hudson's maxdip program and for libsequence tools, into genotype data appropriate for estimation of F statistics in heirfstat. Note that the script deals with the genotype information, but to calculate F statistics the user will need to provide a population identifier for each sample.

An example genotyping file "genotypes.txt" is included with Perl code.