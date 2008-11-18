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
    name      => 'qwetyg',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

my $lang = 'ua';

$u = User->new( id => $u->id );
$u->load( i18n => $lang );

$u->i18n->signature( 'foobar' );
$u->save();

$u = User->new( id => $u->id );
$u->load( i18n => $lang );

is( $u->i18n->lang, $lang );

is( $u->i18n->signature, 'foobar' );

is( $u->i18n->istran, 1 );

$u->delete( cascade => 1 );

1;
