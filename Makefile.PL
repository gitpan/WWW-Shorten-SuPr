use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'WWW::Shorten::SuPr',
    AUTHOR              => q{Anwesh <kanishka@cpan.org>},
    VERSION_FROM        => 'lib/WWW/Shorten/SuPr.pm',
    ABSTRACT_FROM       => 'lib/WWW/Shorten/SuPr.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'WWW-Shorten-SuPr-*' },
);
