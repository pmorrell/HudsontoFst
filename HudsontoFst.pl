#!/usr/bin/env perl
use warnings;
use strict;
use File::Slurp 'read_file';
use List::MoreUtils qw(mesh);
# Peter L. Morrell, St. Paul, MN
# 9 September 2012
# Thanks to Rob Schaefer for help with the final print statement!

# This script turns genotype data in two row format into a single row format.
# data is on two lines, and in the example below has four SNPs
# fred_a	A	A	T	T
# fred_b	G	A	T	A

# The Hudson table format includes three additional rows of headers.
# The SNP positions (second row) are used for locus names in output.

# read_file is from Slurp
# file can have any name, e.g., "Perl HudsontoFasta.pl walrus_genotypes.txt"
# if no file name is given, the script will look for genotypes.txt in the working directory
#my $file = shift or die "Usage: HudsontoFst.pl <filename>\n";
my $file = shift or die 'filename!';

my @lines = read_file($file);

# strip the first line with size information
shift @lines;

# grab positions, then strip the line from the array
my $positions = $lines[0];
shift @lines;

#strip the line for ancestral
shift @lines;

# print a column header for sample names
print "Samples\t";

# add a prefix to SNP positions so they can be easily read into R
# join sample names 
my $prefix = "\tL_";

print join($prefix , split(/\s+/, $positions)),"\n";

# store an index of both odd and even lines in the file
# not fancy, but it works
my @odd = do {my $i = 1; grep {$i++ % 2} @lines};
my @even = do {my $i = 0; grep {$i++ % 2} @lines};

# need to iterate over number of individuals in the Hudson file
# that is half the number of rows (minus headers)
my $list = $#lines / 2; 
foreach my $i (0 .. $list) {
    
    # split rows into new arrays
    my @odd1 = split(/\s/,$odd[$i]);
    my @even1 = split(/\s/,$even[$i]);
    
    # use mesh from MoreUtils to intertwine the genotypes
    my @genotypes = mesh @odd1, @even1;
    
    # here, need to rejoin the genotypes
    # from above would be 
    # fred	AG	AA	TT	TA
    
    # change nucleotide calls to numeric values that can be used in heirfstat
    map { $genotypes[$_] =~ tr/ACGT/1234/ } 1..$#genotypes;
    
    #genotypes should now look like
    #fred	13	11	44	41
    
    # First print out the individuals name (stored in the beginning of the array)
    print $genotypes[0];
    # iterate over the genotypes array (excluding the name columns: 0 and 1)
    for (2..$#genotypes){
        # add a leading tab if we are on an even iteration
        print "\t" if $_ % 2 == 0;
        # print out the genotypes
        print $genotypes[$_];
    }
    # print out a new line character
    print "\n";
}
