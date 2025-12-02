use strict;
use warnings;
use 5.32.1;

my $srcFile = "TWL06.txt";
my $outFile = "words_5letters.txt";

my $fh;

open ($fh, "<", $srcFile) or die "Couldn't open $srcFile!";

say "Loading $srcFile...";
my @lines = map { chomp; $_ } <$fh>;
# say $lines[1];
close $fh;

open ($fh, ">", $outFile) or die "Couldn't open $outFile for output!";

say "Writing to $outFile...";
@lines = grep { 5 == length } @lines;

my $count = 0;
# say $fh $_ foreach @lines;
foreach my $line (@lines) {
  say $fh $line;
  $count++
}

say "Written ".$count." lines to $outFile";

close $fh;
