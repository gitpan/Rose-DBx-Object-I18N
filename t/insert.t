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
    name      => 'foo',
    orig_lang => 'en'
);

is( $u->name,      'foo' );
is( $u->orig_lang, 'en' );

$u->user_i18n( { signature => 'hello' } );
is( scalar @{ $u->user_i18n }, 1 );

$u->save();

is( scalar @{ $u->user_i18n }, 3 );

$u->delete( cascade => 1 );

1;
