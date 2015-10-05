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

sub _build_special_url {
    my ($self, $path, $options) = @_;
    my $base = $self->_build_url_base();
    my $url = $base . $path . $self->_build_query_string($options);
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
    my ($self, $url) = @_;
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

my $champ_v = 'v1.2';

sub get_champions {
    my ($self, $free_to_play, $options) = @_;
    my %options = (
        freeToPlay => $free_to_play ? 'true' : 'false',
    );
    my $url = $self->_build_url('api/lol/', $options->{ api_version } || $champ_v, "champion", \%options);
    return $self->_build_json($url)->{champions};
}

sub get_champion {
    my ($self, $id, $options) = @_;
    my $url = $self->_build_url('api/lol/', $options->{ api_version } || $champ_v, "champion/$id");
    return $self->_build_json($url);
}

#
# Current Game
#

my %platform_ids = (
    na   => 'NA1',
    br   => 'BR1',
    lan  => 'LA1',
    las  => 'LA2',
    oce  => 'OC1',
    eune => 'EUN1',
    tr   => 'TR1',
    ru   => 'RU',
    euw  => 'EUW1',
    kr   => 'KR',
);

sub get_current_game {
    my ($self, $summoner_id) = @_;
    my $platform_id = $platform_ids{$self->region};
    my $url = $self->_build_special_url("observer-mode/rest/consumer/getSpectatorGameInfo/$platform_id/$summoner_id");
    return $self->_build_json($url);
}

#
# Featured Games
#

sub get_featured_games {
    my $self = shift;
    my $url = $self->_build_special_url("observer-mode/rest/featured");
    return $self->_build_json($url);
}

#
# Games
#

my $game_v = 'v1.3';

sub get_recent_games {
    my ($self, $summoner_id, $options) = @_;
    my $url = $self->_build_url("api/lol/", $options->{ api_version } || $game_v, "game/by-summoner/$summoner_id/recent");
    return $self->_build_json($url);
}

1;
