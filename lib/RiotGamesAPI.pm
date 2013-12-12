package RiotGamesAPI;

use LWP::Simple;
use JSON qw( decode_json );
use strict;
use warnings;

use Exporter qw( import );

our @EXPORT_OK = qw(
    set_region
    set_api_key
    get_champions
    get_game_by_id
    get_league_by_id
    get_summoner_by_name
);

my $url_base = "http://prod.api.pvp.net/api/";
my $region;
my $api_key;

sub set_region {
    ($region) = @_;
}

sub set_api_key {
    ($api_key) = @_;
}

sub make_lol_api_call {
    my ($lookup) = @_;
    decode_json( get($url_base . "lol/" . $region . $lookup . "?api_key=$api_key") );
}

sub make_api_call {
    my ($lookup) = @_;
    decode_json( get($url_base . $region . $lookup . "?api_key=$api_key") );
}

sub get_champions {
    make_lol_api_call("/v1.1/champion");
}

sub get_game_by_id {
    my ($summonerid) = @_;
    make_lol_api_call("/v1.1/game/by-summoner/$summonerid/recent");
}

sub get_league_by_id {
    my ($summonerid) = @_;
    make_api_call("/v2.1/league/by-summoner/$summonerid");
}

sub get_summoner_by_name {
    my ($username) = @_;
    make_lol_api_call("/v1.1/summoner/by-name/$username");
}

1;
