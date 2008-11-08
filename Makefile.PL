use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Rose::DBx::Object::I18N',
    AUTHOR              => 'Viacheslav Tikhanovskii <viacheslav.t@gmail.com>',
    VERSION_FROM        => 'lib/Rose/DBx/Object/I18N.pm',
    ABSTRACT_FROM       => 'lib/Rose/DBx/Object/I18N.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Carp' => 0,
        'Hash::Merge' => 0,
        'Rose::DB::Object' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Rose-DBx-Object-I18N-*' },
);
