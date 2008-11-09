#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 11;

use lib 't/lib';

use NewDB;
use User;
use User::Manager;

my $db = NewDB->new();

$db->init();

my $u1 = User->new(
    name      => 'foobar',
    orig_lang => 'en',
    signature => 'hello'
);
$u1->save();

my $u2 = User->new(
    name      => 'fooba',
    orig_lang => 'ru',
    signature => 'hallo'
);
$u2->save();

$ENV{ RDBO_I18N_LANG } = undef;

my $users = User::Manager->get_objects();

is( scalar @$users,                  2 );
is( $users->[ 0 ]->i18n_is_loaded(), 0 );

is( $users->[ 0 ]->i18n->lang, 'en' );
is( $users->[ 1 ]->i18n->lang, 'ru' );

$ENV{ RDBO_I18N_LANG } = 'en';

$users = User::Manager->get_objects();

is( scalar @$users,                  2 );
is( $users->[ 0 ]->i18n_is_loaded(), 1 );

is( $users->[ 0 ]->i18n->lang, 'en' );
is( $users->[ 1 ]->i18n->lang, 'en' );

$users = User::Manager->get_objects( i18n => 'ru' );

is( scalar @$users, 2 );

is( $users->[ 0 ]->i18n->lang, 'ru' );
is( $users->[ 1 ]->i18n->lang, 'ru' );

$_->delete( cascade => 1 ) foreach @$users;
