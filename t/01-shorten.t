use strict;
use warnings;
use Test::More tests => 6;

BEGIN {
    use_ok('WWW::Shorten::SuPr');
};

my $longurl = q{http://google.com}; #q{http://maps.google.co.uk/maps?f=q&source=s_q&hl=en&geocode=&q=louth&sll=53.800651,-4.064941&sspn=33.219383,38.803711&ie=UTF8&hq=&hnear=Louth,+United+Kingdom&ll=53.370272,-0.004034&spn=0.064883,0.075788&z=14};
SKIP: {
    my $return = makeashorterlink($longurl) or do {
        diag 'No network connectivity?';
        skip 'No network connectivity?', 6;
    };
    like($return, qr{^\Qhttp://su.pr/\E}, "$return looks OK");

    my ($code) = $return =~ /([\w_]+)$/;
    my $prefix = 'http://su.pr/';

    like(makeashorterlink($longurl),        qr/^${prefix}${code}/,  'make it shorter');
    like(makealongerlink($prefix . $code),    qr{$longurl/?},       'make it longer');

    {
        eval { &makeashorterlink() };
        ok($@, 'makeashorterlink fails with no args');
    }
    {
        eval { &makealongerlink() };
        ok($@, 'makealongerlink fails with no args');
    }
}
