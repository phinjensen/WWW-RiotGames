package WWW::RiotGames;

use strict;
use warnings;
use Moo;
use HTTP::Tiny;
use JSON qw/ decode_json /;

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

my $http = HTTP::Tiny->new;

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
    my $url = $base . $path . $self->region . "/$api_version/$lookup" . $self->_build_query_string($options);
    return $url;
}

sub _build_query_string {
    my ($self, $options) = @_;
    my $opt_string = "?api_key=" . $self->api_key;
    foreach my $key (keys %$options) {
        $opt_string .= "&$key=$options->{$key}";
    }
    return $opt_string;
}

sub _build_json {
    my ($self, $path, $api_version, $lookup, $options) = @_;
    my $url = $self->_build_url($path, $api_version, $lookup, $options);
    my $request = $http->get($url);
    if ($request->{success}) {
        return decode_json( $request->{content} );
    } else {
        die "Error fetching data: $request->{status} $request->{reason}";
    }
}

#
# Champions
#

sub get_champions {
    my ($self, $free_to_play, $api_version) = @_;
    my %options = (
        freeToPlay => $free_to_play ? 'true' : 'false',
    );
    return $self->_build_json('api/lol/', 'v1.2', 'champion', \%options)->{champions};
}

1;
