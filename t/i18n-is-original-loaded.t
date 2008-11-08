#! /usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 4;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'asdf',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$u = User->new( id => $u->id );
$u->load( i18n => 'ru' );
ok( $u->i18n_is_original_loaded );

$u->i18n( 'en' );
ok( $u->i18n_is_original_loaded() );

$u->i18n->signature( 'hello2' );
$u->save();
is( $u->i18n->istran, 1 );

ok( !$u->i18n_is_original_loaded() );

$u->delete( cascade => 1 );

1;
