package WWW::Shorten::SuPr;
use 5.006;
use strict;
use warnings;
use base qw( WWW::Shorten::generic Exporter );
our @EXPORT = qw( makeashorterlink makealongerlink);
use Carp;
use JSON::Any;
our $VERSION = '0.01';
sub makeashorterlink {
    my $url = shift or croak 'No URL is passed';
    my $ua = __PACKAGE__->ua();
    my $resp = $ua->post('http://su.pr/api/shorten', [
	longUrl => $url
	]);
	die "Request failed - " . $resp->status_line unless $resp->is_success;
	my $json = JSON::Any->new;
	my $obj  = $json->jsonToObj( $resp->content );
	return ($obj->{results}->{$url}->{shortUrl}) if($obj->{errorCode} == '0');
	return ($obj->{errorMessage});
}
sub makealongerlink{
	my $url = shift or croak 'No URL is passed';
	my $ua = __PACKAGE__->ua();
	    my $resp = $ua->post('http://su.pr/api/expand', [
	shortUrl => $url,version=>1.0
	]);
	die "Request failed - " . $resp->status_line unless $resp->is_success;
	my @hash = split (/\//,$url);
	my $json = JSON::Any->new;
	my $obj  = $json->jsonToObj( $resp->content );
	return ($obj->{results}->{$hash[3]}->{longUrl}) if($obj->{errorCode} == '0');
	return ($obj->{errorMessage});
}
sub shortlinkwithauth{
	my ($url,$login,$api) = @_ or croak 'Failed to pass one of the parameters';
	my $ua = __PACKAGE__->ua();
	my $resp = $ua->post('http://su.pr/api/shorten', [
	longUrl => $url,
	login=>$login,
	apiKey=>$api
	]);
	die "Request failed - " . $resp->status_line unless $resp->is_success;
	my $json = JSON::Any->new;
	my $obj  = $json->jsonToObj( $resp->content );
	return ($obj->{results}->{$url}->{shortUrl}) if($obj->{errorCode} == '0');
	return ($obj->{errorMessage});
}
sub socialpost{
	my ($msg,$login,$api) = @_ or croak 'Failed to pass one of the parameters';
	my $ua = __PACKAGE__->ua();
	my $resp = $ua->get("http://su.pr/api/post?&msg=$msg&login=$login&apiKey=$api");
	die "Request failed - " . $resp->status_line unless $resp->is_success;
	my $json = JSON::Any->new;
	my $obj  = $json->jsonToObj( $resp->content );
	return ($obj->{results}->{shortMsg}) if($obj->{errorCode} == '0');
	return ($obj->{errorMessage});
}
sub schedule_socialpost{
	my ($msg,$login,$api,$time) = @_ or croak 'Failed to pass one of the parameters';
	my $ua = __PACKAGE__->ua();
	my $resp = $ua->get("http://su.pr/api/post?&msg=$msg&login=$login&apiKey=$api&timestamp=$time");
	die "Request failed - " . $resp->status_line unless $resp->is_success;
	my $json = JSON::Any->new;
	my $obj  = $json->jsonToObj( $resp->content );
	return ($obj->{results}->{shortMsg}) if($obj->{errorCode} == '0');
	return ($obj->{errorMessage});
}
1;

=pod

=encoding utf-8

=head1 NAME

WWW::Shorten::SuPr - shorten or lengthen URLs with http://su.pr from Stumbleupon
Documentation can be found on http://www.stumbleupon.com/help/su-pr-api/

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

	use WWW::Shorten::SuPr;
	my $url = q{http://perl.org};
	my $short_url = makeashorterlink($url);
	my $long_url  = makealongerlink($short_url); # eq $url
	my $shortlinkwithauth = shortlinkwithauth($url,$login,$api);
	my $socialpost = WWW::Shorten::SuPrsocialpost($msg,$login,$api); # Su.pr provides a update your twitter and facebook wall with a message and shorten the link's provided in the message
	my $schedule_socialpost =WWW::Shorten::SuPr->schedule_socialpost($msg,$login,$api,$time);#Schedule the posts (time should be in unix format)

=head1 SUBROUTINES/METHODS

=head2 makeashorterlink

The function C<makeashorterlink> will call the is.gd web site passing it your long URL and will return the shortened link.

=head2 makealongerlink

The function C<makealongerlink> does the reverse of c<makeashorterlink> if the link already been hashed in Su.Pr

=head2 shortlinkwithauth

Authenticated requests can be used to create account based unique short URLs used for Su.pr analytics. Authenticated items will appear on your Su.pr home page.
Which requires 3 parameters


=over 7

=item URL

	Url Entry supported by Su.Pr

=item Login

	Username of the su.pr
	
=item APIKey

	Api key which can get found in su.pr setting page
	
=back	

=head2 socialpost

The c<socialpost> is used to post Su.pr converted messages to associated services such as Twitter and Facebook. Authentication is required for this API.
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

=head1 AUTHOR

Anwesh, C<< <kanishka at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-shorten-supr at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-Shorten-SuPr>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

you can raise a issue on git hosting L<https://github.com/Anwesh/WWW-Shorten-SuPr/issues>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.
    perldoc WWW::Shorten::SuPr
You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here) L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-Shorten-SuPr>

=item * AnnoCPAN: Annotated CPAN documentation L<http://annocpan.org/dist/WWW-Shorten-SuPr>

=item * CPAN Ratings L<http://cpanratings.perl.org/d/WWW-Shorten-SuPr>

=item * Search CPAN L<http://search.cpan.org/dist/WWW-Shorten-SuPr/>

=item * Git L<https://github.com/Anwesh/WWW-Shorten-SuPr>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Anwesh.
This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
See http://dev.perl.org/licenses/ for more information.
=cut
1; # End of WWW::Shorten::SuPr
