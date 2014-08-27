package WWW::RiotGames;

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
    get_stats_summary_by_id
    get_stats_ranked_by_id
    get_summoner_masteries_by_id
    get_summoner_runes_by_id
    get_summoner_by_name
    get_summoner_by_id
    get_summoner_names_by_ids
    get_teams_by_summoner
);

my $region;
my $api_key;

sub set_region {
    $region = shift;
}

sub set_api_key {
    $api_key = shift;
}

sub make_api_call {
    my $lookup = shift;
    my $url_base = "http://$region.api.pvp.net/api/";
    my $request_url = $url_base . "lol/" . $region . $lookup . "?api_key=$api_key";
    decode_json get($request_url);
}

# Champions
sub get_champions {
    make_api_call("/v1.2/champion");
}

sub get_champion_by_id {
    my $championid = shift;
    make_api_call("/v1.2/champion/$championid");
};

# Games
sub get_game_by_id {
    my $summonerid = shift;
    make_api_call("/v1.2/game/by-summoner/$summonerid/recent");
}

# League info
sub get_league_by_id {
    my $summonerid = shift;
    make_api_call("/v2.2/league/by-summoner/$summonerid");
}

# Stats
sub get_stats_summary_by_id {
    my $summonerid = shift;
    make_api_call("/v1.2/stats/by-summoner/$summonerid/summary");
}

sub get_stats_ranked_by_id {
    my $summonerid = shift;
    make_api_call("/v1.2/stats/by-summoner/$summonerid/ranked");
}

# Summoner info
sub get_summoner_masteries_by_id {
    my $summonerid = shift;
    make_api_call("/v1.2/summoner/$summonerid/masteries");
}

sub get_summoner_runes_by_id {
    my $summonerid = shift;
    make_api_call("/v1.2/summoner/$summonerid/runes");
}

sub get_summoner_by_name {
    my $username = shift;
    make_api_call("/v1.2/summoner/by-name/$username");
}

sub get_summoner_by_id {
    my $summonerid = shift;
    make_api_call("/v1.2/summoner/$summonerid");
}

sub get_summoner_names_by_ids {
    my $summonerids = shift;
    make_api_call("/v1.2/summoner/$summonerids/name");
}

# Teams

sub get_teams_by_summoner {
    my $summonerid = shift;
    make_api_call("/v2.2/team/by-summoner/$summonerid");
}

1;
