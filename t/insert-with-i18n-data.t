#! /usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 3;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'vti',
    orig_lang => 'ru',
    user_i18n => { signature => 'привет' }
);

is( $u->name, 'vti' );

is( $u->orig_lang, 'ru' );

$u->save();

is( scalar @{ $u->user_i18n }, 3 );

$u->delete( cascade => 1 );

1;
