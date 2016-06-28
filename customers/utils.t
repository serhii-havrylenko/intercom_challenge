#!/usr/bin/perl -w

use strict;
use Test::More tests => 15;
use File::Temp;

use constant {
	OFFICE_LATITUDE  => 53.3381985,
	OFFICE_LONGITUDE => -6.2592576,
};

require_ok('Utils');
can_ok( 'Utils', qw/calculate_distance get_customer_by_distance print_customers_in_range/ );

my $utils = Utils->new;

is( ref $utils, 'Utils', 'Refference of class Utils' );

is(
	$utils->calculate_distance(
		{ latitude => OFFICE_LATITUDE, longitude => OFFICE_LONGITUDE, },
		{ latitude => 52.986375,       longitude => -6.043701, }
	),
	41.6768390957445,
	'Calculate distance between two coordinates'
);

is(
	$utils->calculate_distance(
		{ latitude => OFFICE_LATITUDE, longitude => OFFICE_LONGITUDE, },
		{ latitude => 51.92893,        longitude => -10.27699, }
	),
	313.0975108658,
	'Calculate distance between two coordinates'
);

is(
	$utils->calculate_distance(
		{ latitude => OFFICE_LATITUDE, longitude => OFFICE_LONGITUDE, },
		{ latitude => 0,               longitude => 0, }
	),
	5959.16010016277,
	'Calculate distance between two coordinates'
);

is( $utils->calculate_distance( { latitude => 0, longitude => 0, }, { latitude => 0, longitude => 0, } ),
	0, 'Calculate distance between same coordinates' );

is( $utils->calculate_distance( { latitude => 90, longitude => 90, }, { latitude => 0, longitude => 0, } ),
	10007.5433980103, 'Calculate distance between two coordinates' );

is( $utils->calculate_distance( { latitude => 90, longitude => 90, }, { latitude => -90, longitude => -90, } ),
	20015.0867960206, 'Calculate distance between two coordinates' );

is( $utils->calculate_distance( { latitude => 180, longitude => 180, }, { latitude => -180, longitude => -180, } ),
	0, 'Calculate distance between two same coordinates' );

is(
	$utils->calculate_distance(
		{ latitude => OFFICE_LATITUDE, longitude => 'asd', },
		{ latitude => 0,               longitude => 0, }
	),
	undef,
	'Wrong coordinates for calculating distance'
);

is(
	$utils->calculate_distance(
		{ latitude => OFFICE_LATITUDE, longitude => undef, },
		{ latitude => 0,               longitude => 0, }
	),
	undef,
	'Wrong coordinates for calculating distance'
);

my $customers_fh  = File::Temp->new();
my $customers_str = <<STR;
{"latitude": "52.986375", "user_id": 12, "name": "Christina McArdle", "longitude": "-6.043701", "distance": "41.6768390957445"}
{"latitude": "51.92893", "user_id": 1, "name": "Alice Cahill", "longitude": "-10.27699", "distance": "313.0975108658"}
{"latitude": "51.8856167", "user_id": 2, "name": "Ian McArdle", "longitude": "-10.4240951","distance": "324.217048932441"}
STR

print $customers_fh $customers_str;
$customers_fh->close();

is_deeply(
	[
		$utils->get_customer_by_distance(
			{
				latitude       => OFFICE_LATITUDE,
				longitude      => OFFICE_LONGITUDE,
				distance       => 50,
				customers_file => $customers_fh->filename,
			}
		)
	],
	[
		{
			user_id   => 12,
			name      => 'Christina McArdle',
			latitude  => 52.986375,
			longitude => -6.043701,
			distance  => 41.6768390957445,
		}
	],
	'Select one customer in range 50km'
);

is_deeply(
	[
		$utils->get_customer_by_distance(
			{
				latitude       => OFFICE_LATITUDE,
				longitude      => OFFICE_LONGITUDE,
				distance       => 320,
				customers_file => $customers_fh->filename,
			}
		)
	],
	[
		{
			user_id   => 12,
			name      => 'Christina McArdle',
			latitude  => 52.986375,
			longitude => -6.043701,
			distance  => 41.6768390957445,
		},
		{
			longitude => -10.27699,
			distance  => 313.0975108658,
			user_id   => 1,
			latitude  => 51.92893,
			name      => 'Alice Cahill',
		}
	],
	'Select two customer in range 320km'
);

$customers_fh  = File::Temp->new();
$customers_str = <<STR;
{"latitude": "52.986375", "user_id": 12, "name": "Christina McArdle", "longitude": "-6.043701", "distance": "41.6768390957445"}
NON_JSON_LINE
{"latitude": "51.92893", "user_id": 1, "name": "Alice Cahill", "longitude": "-10.27699", "distance": "313.0975108658"}
{WRONG_DATA}
{"latitude": "51.8856167", "user_id": 2, "name": "Ian McArdle", "longitude": "-10.4240951","distance": "324.217048932441"}
{"latitude": "51.8856167"}
STR

print $customers_fh $customers_str;
$customers_fh->close();

is_deeply(
	[
		$utils->get_customer_by_distance(
			{
				latitude       => OFFICE_LATITUDE,
				longitude      => OFFICE_LONGITUDE,
				distance       => 50,
				customers_file => $customers_fh->filename,
			}
		)
	],
	[
		{
			user_id   => 12,
			name      => 'Christina McArdle',
			latitude  => 52.986375,
			longitude => -6.043701,
			distance  => 41.6768390957445,
		}
	],
	'Select one customer in range 50km and with wrong lines'
);
