#!/usr/bin/env perl

use strict;
use warnings;

use Utils;
use Data::Dumper;

my $array = [ [ 1, 2, [ 3, 4 ] ], 5 ];

print Dumper( Utils->new->flatten_arrays($array) );
