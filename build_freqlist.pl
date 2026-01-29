use strict;
use warnings;
use 5.32.1;

my $srcFile = "freqlist.txt";
my $outFile = "freqlist_filtered.txt";

my $fh;

open ($fh, "<", $srcFile) or die "Couldn't open $srcFile!";

say "Loading $srcFile...";
my @lines = map { chomp; $_ } <$fh>;
close $fh;

say "Found " . (scalar @lines) . " lines";