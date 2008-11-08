#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 4;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u = User->new(
    name      => 'qqqq',
    orig_lang => 'ru',
    signature => 'hello'
);
$u->save();

$u = User->new( id => $u->id );
$u->load();
my @i18n = @{ $u->user_i18n };

$u->delete( cascade => 1 );

$u = User->new( id => $u->id );
$u->load( speculative => 1 );
ok( $u->not_found );

foreach my $i18n ( @i18n ) {
    $u = UserI18N->new( i18nid => $i18n->i18nid );
    $u->load( speculative => 1 );
    ok( $u->not_found );
}

1;
