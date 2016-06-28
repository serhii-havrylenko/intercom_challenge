#!/usr/bin/perl -w

use strict;
use Test::More tests => 11;

require_ok('Utils');
can_ok( 'Utils', qw/flatten_arrays/ );

my $utils = Utils->new;

is( ref $utils, 'Utils', 'Refference of class Utils' );

is_deeply( scalar $utils->flatten_arrays( [ [ 1, 2 ], 3 ] ), [ 1, 2, 3 ], 'flatten_arrays with array in array' );
is_deeply( scalar $utils->flatten_arrays( [ [ 1, 2, [3] ], 4 ] ), [ 1, 2, 3, 4 ], 'flatten_arrays deeply' );
is_deeply( scalar $utils->flatten_arrays( [ [ 1, 2, [3] ], [ 4, [5] ] ] ), [ 1, 2, 3, 4, 5 ], 'flatten_arrays deeply' );
is_deeply(
	scalar $utils->flatten_arrays( [ [ 5, 4, [3] ], [ 2, [1] ] ] ),
	[ 5, 4, 3, 2, 1 ],
	'flatten_arrays deeply saves order'
);

is_deeply( scalar $utils->flatten_arrays( [ [ 1, 2, [3] ], [4,[]] ] ), [ 1, 2, 3,4 ], 'flatten_arrays deeply with empty array' );
is_deeply( scalar $utils->flatten_arrays( [ [ 1, 2, [3] ], [4,[undef]] ] ), [ 1, 2, 3,4,undef ], 'flatten_arrays deeply array with undef element' );

is_deeply( scalar $utils->flatten_arrays( [] ), [ ], 'flatten_arrays deeply empty list' );
is_deeply( scalar $utils->flatten_arrays( undef ), undef, 'flatten_arrays deeply undef element' );
