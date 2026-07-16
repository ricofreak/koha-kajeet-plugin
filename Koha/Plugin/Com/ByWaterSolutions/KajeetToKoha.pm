package Koha::Plugin::Com::ByWaterSolutions::KajeetToKoha;

use Modern::Perl;

use Koha::Plugin::Com::ByWaterSolutions::KajeetToKoha::API;

use base qw(Koha::Plugins::Base);

use JSON qw( encode_json decode_json );
use Try::Tiny;
use Koha::Encryption;
use Koha::ItemTypes;

our $VERSION = "0.0.1";

our $metadata = {
    name             => 'Kajeet API plugin',
    author           => 'Lucas Gass',
    description      => 'A plugin to integrate Kajeet services with Koha  ',
    date_authored    => '2026-07-13',
    date_updated     => '2026-07-13',
    minimum_version  => '25.1100000',
    maximum_version  => '26.1199000',
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

sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    unless ( $cgi->param('save') ) {
        my $template = $self->get_template( { file => 'configure.tt' } );

        my $stored_itemtypes = $self->retrieve_data('itemtypes');
        my %selected =
            map { $_ => 1 }
            @{ $stored_itemtypes ? decode_json($stored_itemtypes) : [] };

        $template->param(
            api_base_url       => $self->retrieve_data('api_base_url'),
            username           => $self->retrieve_data('username'),
            password_is_set    => ( $self->retrieve_data('password') ? 1 : 0 ),
            selected_itemtypes => \%selected,
            itemtypes          => Koha::ItemTypes->search_with_localization,
        );

        $self->output_html( $template->output() );
    }
    else {
        my $data = {
            api_base_url => scalar $cgi->param('api_base_url'),
            username     => scalar $cgi->param('username'),
            itemtypes    => encode_json( [ $cgi->multi_param('itemtypes') ] ),
        };

        my $new_password = scalar $cgi->param('password');
        if ( defined $new_password && length $new_password ) {
            my $encrypted = try {
                Koha::Encryption->new->encrypt_hex($new_password);
            }
            catch {
                warn "Could not encrypt password. Die here.";
                undef;
            };

            if ($encrypted) {
                $data->{password} = $encrypted;
            }
            else {
                my $template = $self->get_template( { file => 'configure.tt' } );
                $template->param(
                    error              => 'encryption_unavailable',
                    api_base_url       => $data->{api_base_url},
                    username           => $data->{username},
                    password_is_set    => ( $self->retrieve_data('password') ? 1 : 0 ),
                    selected_itemtypes => { map { $_ => 1 } $cgi->multi_param('itemtypes') },
                    itemtypes          => Koha::ItemTypes->search_with_localization,
                );
                return $self->output_html( $template->output() );
            }
        }

        $self->store_data($data);
        $self->go_home();
    }
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

