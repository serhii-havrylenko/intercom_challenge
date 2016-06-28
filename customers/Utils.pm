package Utils;

use strict;
use warnings;

use Carp;
use JSON;
use Math::Trig;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);

sub new {
	my ($class) = @_;
	$class = ref $class if ref $class;

	return bless {}, $class;
}

=calculate_distance

    Calculate distance from one position to another using formula from https://en.wikipedia.org/wiki/Great-circle_distance

    Input parameters:
        1 - hash ref with latitude and longitude values for first point
        2 - hash ref with latitude and longitude values for second point

    Output:
        distance in kilometers from one point to another

    Examples:
        my $distance = $utils->calculate_distance(
            {
                latitude  => 50,
                longitude => 50,
            },
            {
                latitude  => 45,
                longitude => 45,
            }
        );
=cut

sub calculate_distance {
	my ( $self, $from, $to ) = @_;

	unless ( looks_like_number( $from->{latitude} )
		&& looks_like_number( $from->{longitude} )
		&& looks_like_number( $to->{latitude} )
		&& looks_like_number( $to->{longitude} ) )
	{
		warn "Coordinates do not look like numbers";
		return;
	}

	my ( $latitude_from, $latitude_to, $delta_latitude, $delta_longitude );
	my $earth_radius = 6371;
	eval {
		$latitude_from   = deg2rad( $from->{latitude} );
		$latitude_to     = deg2rad( $to->{latitude} );
		$delta_latitude  = deg2rad( $from->{latitude} - $to->{latitude} );
		$delta_longitude = deg2rad( $from->{longitude} - $to->{longitude} );
	};
	if ($@) {
		warn "Cannot parse coordinates: " . Dumper($@);
		return;
	}

	my $central_angle = 2 * asin(
		sqrt(
			sin( $delta_latitude / 2 )**2 + cos($latitude_from) * cos($latitude_to) * ( sin( $delta_longitude / 2 )**2 )
		)
	);

	return $earth_radius * $central_angle;
}

=get_customer_by_distance

    Get list of customers in specified distance and started position.

    Input parameters:
        Hash ref with starting coordinates. distance and file name with customers details

    Output:
        List of customer in specified range with fields user_id, name, latitude, longitude

    Examples:
        my @customers = $self->get_customer_by_distance({
            latitude       => 50,
            longitude      => 50,
            distance       => 100,
            customers_file => './customers.json',
        });

=cut

sub get_customer_by_distance {
	my ( $self, $args ) = @_;

	return unless -f $args->{customers_file};

	open my $customers_fh, '<', $args->{customers_file} or croak("Cannot open file $args->{customers_file}");

	my @selected_customers;

=comment
    read line by line from file for saving memory.
    we do not know how much lines will be in a file.
    reading all data in memory is not the best solution for this
=cut

	while ( my $customer_json = <$customers_fh> ) {
		my $customer;
		eval { $customer = from_json($customer_json); };
		if ($@) {
			warn "Cannot parse line: " . Dumper($customer_json);
			next;
		}

		my $distance = $self->calculate_distance(
			{
				latitude  => $args->{latitude},
				longitude => $args->{longitude},
			},
			{
				latitude  => $customer->{latitude},
				longitude => $customer->{longitude},
			}
		);

		push @selected_customers, $customer if $distance && $distance < $args->{distance};
	}

	close $customers_fh;

	return @selected_customers;
}

=print_customers_in_range

    Print sorted list of customers by user_id in specified distance and started position.

    Input parameters:
        Hash ref with starting coordinates. distance and file name with customers details

    Output:
        List of customer in specified range with fields user_id, name, latitude, longitude

    Examples:
        my @customers = $self->print_customers_in_range({
            latitude       => 50,
            longitude      => 50,
            distance       => 100,
            customers_file => './customers.json',
        });

=cut

sub print_customers_in_range {
	my ( $self, $args ) = @_;

	my @customers = $self->get_customer_by_distance($args);

	print $_->{user_id} . ' ' . $_->{name} . "\n" foreach sort { $a->{user_id} <=> $b->{user_id} } @customers;
}

1;
