#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite is required to run this test" if $@;

plan 'tests' => 4;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'fake',
    orig_lang => 'ru',
    signature => 'привет'
);

is( $u->name, 'fake' );

is( $u->orig_lang, 'ru' );

$u->save();

is( scalar @{ $u->user_i18n }, 3 );

is( $u->i18n('ru')->signature, 'привет' );

$u->delete( cascade => 1 );

1;
