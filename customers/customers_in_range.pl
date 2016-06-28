#!/usr/bin/env perl

use strict;
use warnings;

use Utils;
use Carp;
use Getopt::Long;

use constant {
	OFFICE_LATITUDE  => 53.3381985,
	OFFICE_LONGITUDE => -6.2592576,
	DISTANCE         => 100,
};

my $usage = << 'HELP';
Usage:
        ./customers_in_range.pl -f|--file FILE [-d|--distance DISTANCE]

            -f||--file       File with customers information
            -d|--distance    Distance in kilometers for selecting customers. Default 100km
HELP

my %params = (
	file     => undef,
	distance => DISTANCE,
);
GetOptions(
	"f|file=s"     => \$params{file},
	"d|distance=i" => \$params{distance},
) or croak($usage);

croak("File not found") unless $params{file} && -f $params{file};

my $utils = Utils->new;
$utils->print_customers_in_range(
	{
		latitude       => OFFICE_LATITUDE,
		longitude      => OFFICE_LONGITUDE,
		distance       => $params{distance},
		customers_file => $params{file},
	}
);
