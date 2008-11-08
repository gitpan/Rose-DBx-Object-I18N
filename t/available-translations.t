#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 5;

use lib 't/lib';

use NewDB;
use User;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'oooo',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$ENV{ LANG } = 'ru';
$u = User->new( id => $u->id );
$u->load();

$u->i18n();
is_deeply( $u->i18n_available_translations, [] );

$u->i18n( 'en' )->signature( 'hello2' );
$u->save();

is( $u->i18n_is_original_loaded(), 0 );
is_deeply( $u->i18n_available_translations, [ 'ru' ] );

$u->i18n( 'ru' );
is_deeply( $u->i18n_available_translations, [ 'en' ] );

$u->i18n( 'ua' );
is_deeply( $u->i18n_available_translations, [ 'en' ] );

$u->delete( cascade => 1 );

1;
