package Koha::Plugin::Com::ByWaterSolutions::KajeetToKoha;

use Modern::Perl;

use base qw(Koha::Plugins::Base);
use JSON;

our $VERSION = "0.0.1";

our $metadata = {
    name             => 'KajeetToKoha',
    author           => 'Lucas Gass',
    description      => 'A plugin to integrate Kajeet services with Koha  ',
    date_authored    => '2026-07-13',
    date_updated     => '2026-07-13',
    minimum_version  => '25.1100000',
    maximum_version  => '25.1199000',
    version          => $VERSION,
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);

    return $self;
}

sub install {
    my ( $self, $args ) = @_;

    return 1;
}

sub upgrade {
    my ( $self, $args ) = @_;

    return 1;
}

sub uninstall {
    my ( $self, $args ) = @_;

    return 1;
}

sub static_routes {
    my ( $self, $args ) = @_;

    my $spec_str = $self->mbf_read('staticapi.json');
    my $spec     = decode_json($spec_str);

    return $spec;
}

sub api_namespace {
    my ($self) = @_;
    return 'bywatersolutions_kajeettokoha';
}

sub intranet_head {
    my ( $self ) = @_;

    return q|
   <script src="/api/v1/contrib/bywatersolutions_kajeettokoha/static/js/kajeettokoha.js" type="module"></script>
   <link rel="stylesheet" href="/api/v1/contrib/bywatersolutions_kajeettokoha/static/css/kajeettokoha.css">
|;
}
