#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite is required to run this test" if $@;

plan 'tests' => 2;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'barfoo',
    orig_lang => 'en',
    signature => 'hello'
);
$u->save();
my $id = $u->id;

$u = User->new( id => $id );
$u->load(
    query => [ 't2.lang' => 'ru' ],
    with  => [ 'user_i18n' ]
);

is( $u->name, 'barfoo' );

is( $u->i18n->lang, 'ru' );

$u->delete( cascade => 1 );

1;
