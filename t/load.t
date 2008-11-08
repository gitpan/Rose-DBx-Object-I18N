#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 5;

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

$ENV{ LANG } = 'en';
$u = User->new( id => $u->id );
$u->load();

is( $u->i18n->lang,      'en' );
is( $u->i18n->signature, 'hello' );

is( $u->i18n( 'ru' )->lang, 'ru' );

$u = User->new( id => $u->id );
$u->load();
$ENV{ LANG } = 'ru';
is( $u->i18n->lang, 'ru' );

$u = User->new( id => $u->id );
$u->load();
$ENV{ LANG } = 'en';
is( $u->i18n->lang, 'en' );

$u->delete( cascade => 1 );
