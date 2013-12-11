package RiotGamesAPI;

use LWP::Simple;
use JSON qw( decode_json );
use strict;
use warnings;

use Exporter qw( import );

our @EXPORT_OK = qw( get_summoner_by_name set_region set_api_key );

my $url_base = "http://prod.api.pvp.net/api/lol/";
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
    decode_json( get($base_url . $region . $lookup . "?api_key=$api_key") );
}

sub get_summoner_by_name {
    my ($username) = @_;
    make_lol_api_call("/v1.1/summoner/by-name/$username");
}

1;
