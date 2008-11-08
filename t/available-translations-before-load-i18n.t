#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 1;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'ipoi',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$u = User->new( id => $u->id );
$u->load();

eval { $u->i18n_available_translations() };
ok( $@ );

$u->delete( cascade => 1 );

1;
