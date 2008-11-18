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
    name      => '12345a',
    orig_lang => 'ru',
    signature => 'hallo'
);
$u->save();

$u->i18n->signature( 'wow' );
$u->save();
is( $u->i18n( 'ru' )->signature, 'wow' );

is( $u->i18n( 'en' )->istran, 0 );

is( $u->i18n->signature, 'wow' );

$u->delete( cascade => 1 );

1;
