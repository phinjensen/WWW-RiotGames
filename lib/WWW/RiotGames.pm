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

sub _is_valid_ranked_type {
    my ($self, $type) = @_;
    return grep(/^$type$/, qw/RANKED_SOLO_5x5 RANKED_TEAM_3x3 RANKED_TEAM_5x5/);
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

sub _build_global_url {
    my ($self, $path, $api_version, $lookup, $options) = @_;
    my $base = $self->_build_url_base(1);
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

sub _validate_summoner_list {
    my ($self, $list, $max) = @_;
    if ($list =~ /^(\d+,)*\d+$/) {
        my @summoners = split(/,/,$list);
        scalar @summoners <= $max or die "List is too long for request! Maximum length is $max";
    } else {
        die "Summoner IDs should be a comma-seperated list of numbers.";
    }
}

sub _validate_team_list {
    my ($self, $list, $max) = @_;
    if ($list =~ /^(TEAM-[a-f0-9\-]+,)*TEAM-[a-f0-9\-]+$/) {
        my @teams = split(/,/,$list);
        scalar @teams <= $max or die "List is too long for request! Maximum length is $max";
    } else {
        die "Please provide a comma-seperated list of team IDs.";
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

#
# Leagues
#

my $league_v = 'v2.5';

sub get_league_by_summoner {
    my ($self, $summoner_ids, $options) = @_;
    $self->_validate_summoner_list($summoner_ids, 10);
    my $url = $self->_build_url("api/lol/",
                                $options->{ api_version } || $league_v,
                                "league/by-summoner/$summoner_ids");
    return $self->_build_json($url);
}

sub get_league_entries_by_summoner {
    my ($self, $summoner_ids, $options) = @_;
    $self->_validate_summoner_list($summoner_ids, 10);
    my $url = $self->_build_url("api/lol/",
                                $options->{ api_version } || $league_v,
                                "league/by-summoner/$summoner_ids/entry");
    return $self->_build_json($url);
}

sub get_league_by_team {
    my ($self, $team_ids, $options) = @_;
    $self->_validate_team_list($team_ids, 10);
    my $url = $self->_build_url("api/lol/",
                                $options->{ api_version } || $league_v,
                                "league/by-team/$team_ids");
    return $self->_build_json($url);
}

sub get_league_entries_by_team {
    my ($self, $team_ids, $options) = @_;
    $self->_validate_team_list($team_ids, 10);
    my $url = $self->_build_url("api/lol/",
                                $options->{ api_version } || $league_v,
                                "league/by-team/$team_ids/entry");
    return $self->_build_json($url);
}

sub get_challenger_league {
    my ($self, $type, $options) = @_;
    $self->_is_valid_ranked_type($type) or die "Ranked type must be one of: RANKED_SOLO_5x5 RANKED_TEAM_5x5 RANKED_TEAM_3x3";
    my $url = $self->_build_url("api/lol/",
                                $options->{ api_version } || $league_v,
                                "league/challenger",
                                { type => $type });
    return $self->_build_json($url);
}

sub get_master_league {
    my ($self, $type, $options) = @_;
    $self->_is_valid_ranked_type($type) or die "Ranked type must be one of: RANKED_SOLO_5x5 RANKED_TEAM_5x5 RANKED_TEAM_3x3";
    my $url = $self->_build_url("api/lol/",
                                $options->{ api_version } || $league_v,
                                "league/master",
                                { type => $type });
    return $self->_build_json($url);
}

#
# Static Data
#

my $static_v = 'v1.2';

sub get_static_champions {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "champion", $options);
    return $self->_build_json($url);
}

sub get_static_champion_by_id {
    my ($self, $id, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "champion/$id", $options);
    return $self->_build_json($url);
}

sub get_static_items {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "item", $options);
    return $self->_build_json($url);
}

sub get_static_item_by_id {
    my ($self, $id, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "item/$id", $options);
    return $self->_build_json($url);
}

sub get_static_language_strings {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "language-strings", $options);
    return $self->_build_json($url);
}

sub get_static_languages {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "languages", $options);
    return $self->_build_json($url);
}

sub get_static_map {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "map", $options);
    return $self->_build_json($url);
}

sub get_static_masteries {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "mastery", $options);
    return $self->_build_json($url);
}

sub get_static_mastery_by_id {
    my ($self, $id, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "mastery/$id", $options);
    return $self->_build_json($url);
}

sub get_static_realm {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "realm", $options);
    return $self->_build_json($url);
}

sub get_static_runes {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "rune", $options);
    return $self->_build_json($url);
}

sub get_static_rune_by_id {
    my ($self, $id, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "rune/$id", $options);
    return $self->_build_json($url);
}

sub get_static_summoner_spells {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "summoner-spell", $options);
    return $self->_build_json($url);
}

sub get_static_summoner_spell_by_id {
    my ($self, $id, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "summoner-spell/$id", $options);
    return $self->_build_json($url);
}

sub get_static_versions {
    my ($self, $options) = @_;
    my $url = $self->_build_global_url("api/lol/static-data/", $options->{ api_version } || $static_v, "versions", $options);
    return $self->_build_json($url);
}

1;
