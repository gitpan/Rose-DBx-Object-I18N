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
    name      => 'zzz',
    orig_lang => 'en',
    signature => 'hello'
);
$u->save();

$u = User->new( id => $u->id );
$u->load();
ok( $u->i18n );
ok( $u->i18n->lang, 'en' );

eval { $u->i18n( i18n => 'bu' ); };
ok( $@ );

$u->delete( cascade => 1 );

1;
