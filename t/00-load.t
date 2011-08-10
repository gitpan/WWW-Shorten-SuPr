#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::Shorten::SuPr' ) || print "Bail out!\n";
}

diag( "Testing WWW::Shorten::SuPr $WWW::Shorten::SuPr::VERSION, Perl $], $^X" );
