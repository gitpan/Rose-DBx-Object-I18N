#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 2;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'uuu',
    orig_lang => 'en',
    signature => 'hello'
);
$u->save();

$ENV{ LANG } = undef;

$u = User->new( id => $u->id );
$u->load();
is( $u->i18n->lang, 'en' );

is( $u->i18n->signature, 'hello' );

$u->delete( cascade => 1 );

1;
