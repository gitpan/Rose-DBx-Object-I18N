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
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'abcde',
    orig_lang => 'ru',
    signature => 'hi'
);
$u->save();

is( $u->name, 'abcde' );

is( $u->orig_lang, 'ru' );

$u->name( 'fred' );
$u->save();

is( $u->i18n->istran, 0 );

$u->delete( cascade => 1 );

1;
