#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite is required to run this test" if $@;

plan 'tests' => 5;

use lib 't/lib';

use NewDB;
use User;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'foobar',
    orig_lang => 'en',
    signature => 'hello'
);
$u->save();

$ENV{ RDBO_I18N_LANG } = 'en';
$u = User->new( id => $u->id );
$u->load();

is( $u->i18n->lang,      'en' );
is( $u->i18n->signature, 'hello' );

is( $u->i18n( 'ru' )->lang, 'ru' );

$u = User->new( id => $u->id );
$u->load();

$ENV{ RDBO_I18N_LANG } = 'ru';
is( $u->i18n->lang, 'ru' );

$u = User->new( id => $u->id );
$u->load();

$ENV{ RDBO_I18N_LANG } = 'en';
is( $u->i18n->lang, 'en' );

$u->delete( cascade => 1 );
