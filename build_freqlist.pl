# Build Frequency List Script
# By Hevanafa, 29-01-2026

# This script produces a TXT file based on the frequency list from norvig.com

use strict;
use warnings;
use 5.32.1;

my $srcFile = "count_1w.txt";
my $outFile = "freqlist_5letters.txt";

my $fh;

open ($fh, "<", $srcFile) or die "Couldn't open $srcFile!";

say "Loading $srcFile...";
my @lines = map { chomp; $_ } <$fh>;
close $fh;

say "Loaded " . (scalar @lines) . " lines";

@lines = grep {
  my @pair = $_ =~ /[^\t]+/g;
  length($pair[0]) == 5
} @lines;

my $count = 0;
open ($fh, ">", $outFile) or die "Couldn't open $outFile for output!";

foreach my $line (@lines) {
  say $fh $line;
  $count++
}

close $fh;
say "Written $count lines to $outFile"
