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
    name      => 'john',
    orig_lang => 'en',
    signature => 'hello'
);
$u->save();
my $id = $u->id;

$ENV{LANG} = undef;

$u = User->new( id => $id );
$u->load( i18n => 'ru' );

is( $u->name, 'john' );

is( $u->i18n->lang, 'ru' );

$u->delete( cascade => 1 );

1;
