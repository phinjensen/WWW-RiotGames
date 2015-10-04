package WWW::RiotGames;

use strict;
use warnings;
use Moo;
use HTTP::Tiny;

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

sub _is_valid_region {
    my $region = shift;
    return grep(/^$region$/, qw/br eune euw kr lan las na oce ru tr/);
}

sub _build_url_base {
    my ($self, $global) = @_;
    if ($global) {
        return "https://global.api.pvp.net/api/lol/";
    } else {
        return "https://" . $self->region . ".api.pvp.net/api/lol/";
    }
}

1;
