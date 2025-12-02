use strict;
use warnings;
use 5.32.1;

my $srcFile = "TWL06.txt";
my $outFile = "words_5letters.txt";

open (my $fh, "<", $srcFile) or die "Couldn't open $srcFile!";

my @lines = map { chomp; $_ } <$fh>;
say $lines[1];

close $fh;