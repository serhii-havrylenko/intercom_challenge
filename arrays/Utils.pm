package Utils;

use strict;
use warnings;

sub new {
	my ($class) = @_;
	$class = ref $class if ref $class;

	return bless {}, $class;
}

sub flatten_arrays {
	my ( $self, $input_array_ref ) = @_;

	return undef unless $input_array_ref || ref $input_array_ref;

	my @joined_arrays;
	foreach my $element (@$input_array_ref) {
		if ( ref $element && ref $element eq 'ARRAY' ) {
			push @joined_arrays, $self->flatten_arrays($element);
		}
		else {
			push @joined_arrays, $element;
		}
	}

	return wantarray ? @joined_arrays : \@joined_arrays;
}

1;
