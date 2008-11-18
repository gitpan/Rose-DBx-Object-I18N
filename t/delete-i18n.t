#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite is required to run this test" if $@;

plan 'tests' => 3;

use lib 't/lib';

use NewDB;
use User;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'qqqqa',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$u->i18n( 'en' )->signature( 'hallo' );
$u->save();
is( $u->i18n->istran, 1 );

$u->delete_i18n();
is( $u->i18n->istran, 0 );

is( $u->i18n->signature, 'hello' );

$u->delete( cascade => 1 );

1;
