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
    get_shard_list
    get_shard_status
    get_match_by_id
    get_match_history_by_id
);

use version; our $VERSION = qv('0.0.1');

my $region;
my $api_key;

sub set_region {
    $region = shift;
}

sub set_api_key {
    $api_key = shift;
}

sub build_url_parameters {
    my $options_ref = shift;
    my $query_string = '?';
    for my $option_name (keys %$options_ref) {
        $query_string .= "$option_name=" . $options_ref->{$option_name} . "&";
    }
    $query_string .= "api_key=$api_key";
    return $query_string;
}

sub make_api_call {
    my ($lookup, $options_ref) = @_;
    my $url_base = "http://$region.api.pvp.net/api/";
    my $query_string = build_url_parameters($options_ref);
    my $request_url = $url_base . "lol/" . $region . $lookup . $query_string;
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
    my $options_ref = shift;
    make_api_call( "/v1.2/champion", $options_ref );
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
    my $options_ref = shift;
    make_api_call("/v2.5/league/challenger", $options_ref);
}

# Static data
sub get_data_by_type {
    my ($datatype, $id, $options_ref) = @_;
    if ($datatype !~ /champion|item|mastery|realm|rune|summoner-spell|versions/) {
        print "Not a valid static datatype! Please use champion, item, mastery, realm, rune, summoner-spell, or versions.";
    } else {
        my $lookup = "/static-data/$region/v1.2/$datatype";
        if ($id) {
            $lookup .= "/$id";
        }
        make_global_api_call($lookup, $id, $options_ref);
    }
}

# Status
sub get_shard_list {
    decode_json get("http://status.leagueoflegends.com/shards");
};

sub get_shard_status {
    my $region = shift;
    decode_json get("http://status.leagueoflegends.com/shards/$region");
}

# Match Data
sub get_match_by_id {
    my ($matchid, $options_ref) = @_;
    make_api_call("/v2.2/match/$matchid");
}

# Match History
sub get_match_history_by_id {
    my ($summonerid, $options_ref) = @_;
    make_api_call("/v2.2/matchhistory/$summonerid");
}

# Stats
sub get_stats_summary_by_id {
    my ($summonerid, $options_ref) = @_;
    make_api_call("/v1.3/stats/by-summoner/$summonerid/summary");
}

sub get_stats_ranked_by_id {
    my ($summonerid, $options_ref) = @_;
    make_api_call("/v1.3/stats/by-summoner/$summonerid/ranked");
}

# Summoner info
sub get_summoner_masteries_by_id {
    my $summonerid = shift;
    make_api_call("/v1.4/summoner/$summonerid/masteries");
}

sub get_summoner_runes_by_id {
    my $summonerid = shift; make_api_call("/v1.4/summoner/$summonerid/runes");
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
__END__

=head1 NAME

WWW::RiotGames - Wrapper for the Riot Games API


=head1 VERSION

This document describes WWW::RiotGames version 0.0.1


=head1 SYNOPSIS

    use WWW::RiotGames qw( get_champions );

    set_api_key( $my_api_key );
    set_region( $region );

    my $freeweek = get_champions( { freeToPlay => 'true' } );
    my $summoner_id = get_summoner_by_name( 'uncleshelby' )->{ 'id' };
    my $matchhistory = get_match_history_by_id( $summoner_id );


=head1 AUTHOR

Phin Jensen  C<< <phin@zayda.net> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, Phin Jensen C<< <phin@zayda.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
