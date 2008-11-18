#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite is required to run this test" if $@;

plan 'tests' => 9;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'foobar',
    orig_lang => 'en',
    signature => 'hello'
);
$u->save();
my $id = $u->id;

foreach my $lang ( @{ $u->i18n_languages } ) {
    $u->i18n( $lang );
    ok( $u->i18n );

    is( $u->i18n->lang, $lang, );

    is( $u->i18n->signature, 'hello', );
}

$u->delete( cascade => 1 );

1;
