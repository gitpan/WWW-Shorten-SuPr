package WWW::Shorten::SuPr;
# ABSTRACT: shorten or lengthen URLs with http://su.pr
use 5.006;
use strict;
use warnings;

=head1 SYNOPSIS

    use WWW::Shorten::SuPr;
    my $url = q{http://perl.org};
    my $short_url = makeashorterlink($url);

    my $long_url  = makealongerlink($short_url); # eq $url

    my $shortlinkwithauth = shortlinkwithauth($url,$login,$api);

    # Su.pr provides a update your twitter and facebook wall with a
    # message and shorten the links provided in the message
    my $socialpost = WWW::Shorten::SuPrsocialpost($msg,$login,$api);

    #Schedule the posts (time should be in unix format)
    my $schedule_socialpost = WWW::Shorten::SuPr->schedule_socialpost($msg,$login,$api,$time);

=for test_synopsis
1; # Should fix up the synopsis to run under strict
__END__

=cut

use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw( makeashorterlink makealongerlink);
use Carp;
use JSON::Any;
# VERSION

=head1 SUBROUTINES

=head2 makeashorterlink

The function C<makeashorterlink> will call the is.gd web site passing it your
long URL and will return the shortened link.

=cut

sub makeashorterlink {
    my $url  = shift or croak 'No URL is passed to makeashorterlink';
    my $ua   = __PACKAGE__->ua();
    my $resp = $ua->post( 'http://su.pr/api/shorten', [ longUrl => $url ] );
    croak "Request failed - " . $resp->status_line
        unless $resp->is_success;

    my $json = JSON::Any->new();
    my $obj  = $json->jsonToObj( $resp->content );
    return $obj->{results}->{$url}->{shortUrl}
        if $obj->{errorCode} == 0;

    return ( $obj->{errorMessage} );
}

=head2 makealongerlink

The function C<makealongerlink> does the reverse of c<makeashorterlink> if the
link already been hashed in Su.Pr

=cut

sub makealongerlink {
    my $url  = shift or croak 'No URL is passed';
    my $ua   = __PACKAGE__->ua();
    my $resp = $ua->post(
        'http://su.pr/api/expand',
        [
            shortUrl => $url,
            version  => 1.0
        ]
    );
    croak "Request failed - " . $resp->status_line
        unless $resp->is_success;

    my $json = JSON::Any->new;
    my $obj  = $json->jsonToObj( $resp->content );
    return ( $obj->{results}->{ (split m{/}, $url)[3] }->{longUrl} )
        if ( $obj->{errorCode} == '0' );

    return ( $obj->{errorMessage} );
}


=head2 shortlinkwithauth

Authenticated requests can be used to create account based unique short URLs
used for Su.pr analytics. Authenticated items will appear on your Su.pr home
page. Which requires 3 parameters


=over 7

=item URL

    Url Entry supported by Su.Pr

=item Login

    Username of the su.pr
    
=item APIKey

    Api key which can get found in su.pr setting page
    
=back	

=cut

sub shortlinkwithauth {
    my ( $url, $login, $api ) = @_ or croak 'Failed to pass one of the parameters';
    my $ua   = __PACKAGE__->ua();
    my $resp = $ua->post(
        'http://su.pr/api/shorten',
        [
            longUrl => $url,
            login   => $login,
            apiKey  => $api
        ]
    );
    croak "Request failed - " . $resp->status_line
        unless $resp->is_success;

    my $json = JSON::Any->new;
    my $obj  = $json->jsonToObj( $resp->content );
    return ( $obj->{results}->{$url}->{shortUrl} )
        if ( $obj->{errorCode} == '0' );

    return ( $obj->{errorMessage} );
}

=head2 socialpost

The c<socialpost> is used to post Su.pr converted messages to associated services such
as Twitter and Facebook. Authentication is required for this API.
Which requires 3 parameters

=over

=item Message

    msg: blah blah blah http://perl.org
    Note this should not exceded 140 characters
    
=item Login

    Username of the su.pr
    
=item APIKey
    
    Api key which can get found in su.pr setting page
    
=back	

=cut

sub socialpost {
    my ( $msg, $login, $api ) = @_ or croak 'Failed to pass one of the parameters';
    my $ua = __PACKAGE__->ua();
    my $resp = $ua->get("http://su.pr/api/post?&msg=$msg&login=$login&apiKey=$api");
    croak "Request failed - " . $resp->status_line
        unless $resp->is_success;

    my $json = JSON::Any->new;
    my $obj  = $json->jsonToObj( $resp->content );
    return ( $obj->{results}->{shortMsg} )
        if ( $obj->{errorCode} == '0' );

    return ( $obj->{errorMessage} );
}

=head2 schedule_socialpost
    
    
    Schedule a C<socialpost> with unix time stamp .
    Which requires 3 parameters
    
=over

=item Message

    msg: blah blah blah http://perl.org
    Note this should not exceeded 140 characters
    
=item Login
    
    Username of the su.pr
    
=item APIKey

    Api key which can get found in su.pr setting page
    
=item Time

    Unix timestamp of the date and time you wish to post. Posts will be submitted within a 15 minute bucket of the scheduled time.
    
=back	

=cut

sub schedule_socialpost {
    my ( $msg, $login, $api, $time ) = @_ or croak 'Failed to pass one of the parameters';
    my $ua   = __PACKAGE__->ua();
    my $resp = $ua->get("http://su.pr/api/post?&msg=$msg&login=$login&apiKey=$api&timestamp=$time");
    croak "Request failed - " . $resp->status_line
        unless $resp->is_success;

    my $json = JSON::Any->new;
    my $obj  = $json->jsonToObj( $resp->content );
    return ( $obj->{results}->{shortMsg} )
        if ( $obj->{errorCode} == '0' );

    return ( $obj->{errorMessage} );
}

1;
