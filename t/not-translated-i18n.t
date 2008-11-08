#! /usr/bin/perl

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
    name      => 'asdf2aa1',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

my @not_translated = $u->not_translated_i18n;

is_deeply( [ map { $_->lang } @not_translated ], [ 'en', 'ua' ] );

$u->delete( cascade => 1 );

1;
