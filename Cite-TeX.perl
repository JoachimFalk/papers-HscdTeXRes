#! /usr/bin/env perl
# vim: set sw=2 ts=8 sts=2 syn=perl expandtab:

use strict;
use warnings;

my $citation = 0;
while (<>) {
  $citation = 1 if m@^\\citation{@;
}
print "$ENV{STEM}.bbl" if $citation;
