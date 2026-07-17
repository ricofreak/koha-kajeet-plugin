package Koha::Plugin::Com::ByWaterSolutions::KajeetToKoha;

use Modern::Perl;
use JSON qw( encode_json decode_json );
use LWP::UserAgent;
use Koha::Encryption;

sub authenticate {
    my ($self) = @_;

    $self->{_kajeet_ua} //= LWP::UserAgent->new( timeout => 15 );

    my $base_url = $self->retrieve_data('api_base_url')
        || 'https://sentinel-api.kajeet.com/sentinel/api';

    my $res = $self->{_kajeet_ua}->post(
        $base_url . '/v1.0/auth/token',
        'Content-Type' => 'application/json',
        Content        => encode_json({
            username => $self->retrieve_data('username'),
            password => $self->_api_password,
        }),
    );

    die "Kajeet authentication failed (" . $res->code . ")" unless $res->is_success;

    my $data = decode_json( $res->decoded_content );
    $self->{_kajeet_token}   = $data->{token} or die "no token in auth response";
    $self->{_kajeet_corp_id} = $data->{details}->{corpId};

    return;
}

sub _api_password {
    my ($self) = @_;
    my $stored = $self->retrieve_data('password');
    return unless $stored;
    return Koha::Encryption->new->decrypt_hex($stored);
}

1;
