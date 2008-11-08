#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 8;

use lib 't/lib';

use User;

my $u = User->new(
    name      => 'foo',
    orig_lang => 'en',
    user_i18n => {
        signature => 'hello'
    }
);

is( $u->name,      'foo' );
is( $u->orig_lang, 'en' );



my $translation = shift @{ $u->user_i18n };
ok( $translation );
is( $translation->isa( 'UserI18N' ), 1 );

$u = User->new(
    name      => 'foo',
    orig_lang => 'en',
    signature => 'hello'
);

is( $u->name,      'foo' );
is( $u->orig_lang, 'en' );

$translation = shift @{ $u->user_i18n };
ok( $translation );
is( $translation->isa( 'UserI18N' ), 1 );
