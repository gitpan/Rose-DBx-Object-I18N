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
    name      => '12345',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$u->i18n('en')->signature( 'hi' );
$u->save();

is( $u->i18n->lang, 'en' );

is( $u->i18n->signature, 'hi' );

is( $u->i18n->istran, 1 );

$u->delete( cascade => 1 );

1;
