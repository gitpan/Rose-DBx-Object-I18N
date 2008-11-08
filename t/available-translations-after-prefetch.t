#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 2;

use lib 't/lib';

use NewDB;
use User;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'ppp',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$u->load( i18n => 'en' );
is_deeply( $u->i18n_available_translations, [] );

$u->i18n->signature( 'hello2' );
$u->save();
is_deeply( $u->i18n_available_translations, [ 'ru' ] );

$u->delete( cascade => 1 );

1;
