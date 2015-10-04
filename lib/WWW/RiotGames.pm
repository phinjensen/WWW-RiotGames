package WWW::RiotGames;

use strict;
use warnings;
use Moo;
use HTTP::Tiny;
use Data::Dumper;

has api_key => (
    is => 'ro',
);

has region => (
    is => 'rw',
    isa => sub {
        die "$_[0] is not a valid region!" unless _is_valid_region($_[0])
    },
    coerce => sub {
        lc $_[0]
    },
);

#
# Helper functions
#

sub _is_valid_region {
    my $region = shift;
    return grep(/^$region$/, qw/br eune euw kr lan las na oce ru tr/);
}

sub _build_url_base {
    my ($self, $global) = @_;
    if ($global) {
        return "https://global.api.pvp.net/";
    } else {
        return "https://" . $self->region . ".api.pvp.net/";
    }
}

sub _build_url {
    my ($self, $path, $api_version, $lookup, $options) = @_;
    my $base = $self->_build_url_base();
    return $base . $path . $self->region . "/$api_version/$lookup" . $self->_build_query_string($options);
}

sub _build_query_string {
    my ($self, $options) = @_;
    my $opt_string = "?api_key=" . $self->api_key;
    foreach my $key (keys %$options) {
        $opt_string .= "&$key=$options->{$key}";
    }
    return $opt_string;
}

#
# Champions
#

sub get_champions {
    my ($self, $free_to_play, $api_version) = @_;
    my %options = (
        freeToPlay => $free_to_play ? 'true' : 'false',
    );
    return $self->_build_url('api/lol/', 'v1.2', 'champion', \%options);
}

1;
