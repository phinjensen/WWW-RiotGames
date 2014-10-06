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
    get_data_by_type
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

sub make_global_api_call {
    my $lookup = shift;
    my $url_base = "http://global.api.pvp.net/api/lol";
    my $request_url = $url_base . $lookup . "?api_key=$api_key";
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
    make_api_call("/v1.3/game/by-summoner/$summonerid/recent");
}

# League info
sub get_league_by_id {
    my $summonerid = shift;
    make_api_call("/v2.5/league/by-summoner/$summonerid");
}

sub get_league_entry_by_id {
    my $summonerid = shift;
    make_api_call("/v2.5/league/by-summoner/$summonerid/entry");
}

sub get_league_by_team {
    my $teamid = shift;
    make_api_call("/v2.5/league/by-team/$teamid");
}

sub get_league_entry_by_team {
    my $teamid = shift;
    make_api_call("/v2.5/league/by-team/$teamid/entry");
}

sub get_challenger_league {
    make_api_call("/v2.5/league/challenger");
}

# Static data

sub get_data_by_type {
    my ($datatype, $id) = @_;
    if ($datatype !~ /champion|item|mastery|realm|rune|summoner-spell|versions/) {
        print "Not a valid static datatype! Please use champion, item, mastery, realm, rune, summoner-spell, or versions.";
    } else {
        my $lookup = "/static-data/$region/v1.2/$datatype";
        if ($id) {
            $lookup .= "/$id";
        }
        make_global_api_call($lookup, $id);
    }
}

# Stats
sub get_stats_summary_by_id {
    my $summonerid = shift;
    make_api_call("/v1.3/stats/by-summoner/$summonerid/summary");
}

sub get_stats_ranked_by_id {
    my $summonerid = shift;
    make_api_call("/v1.3/stats/by-summoner/$summonerid/ranked");
}

# Summoner info
sub get_summoner_masteries_by_id {
    my $summonerid = shift;
    make_api_call("/v1.4/summoner/$summonerid/masteries");
}

sub get_summoner_runes_by_id {
    my $summonerid = shift;
    make_api_call("/v1.4/summoner/$summonerid/runes");
}

sub get_summoner_by_name {
    my $username = shift;
    make_api_call("/v1.4/summoner/by-name/$username");
}

sub get_summoner_by_id {
    my $summonerid = shift;
    make_api_call("/v1.4/summoner/$summonerid");
}

sub get_summoner_names_by_ids {
    my $summonerids = shift;
    make_api_call("/v1.4/summoner/$summonerids/name");
}

# Teams

sub get_teams_by_summoner {
    my $summonerid = shift;
    make_api_call("/v2.4/team/by-summoner/$summonerid");
}

sub get_team_by_id {
    my $teamid = shift;
    make_api_call("/v2.4/team/$teamid");
}

1;
