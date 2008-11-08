#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'tests' => 6;

use lib 't/lib';

use User;
use UserI18N;

my $static = User->new( name => 'abc' );
ok( $static->meta->i18n_translation_rel_name() );

is( $static->meta->i18n_translation_rel_name(), 'user_i18n' );

ok( not defined $static->meta->i18n_static_rel_name() );

#is_deeply( [ $static->i18n_languages ], [ qw/ ru en ua / ] );

my $translation = UserI18N->new( signature => 'abc' );
ok( $translation->meta->i18n_static_rel_name() );

is( $translation->meta->i18n_static_rel_name(), 'user' );

ok( not defined $translation->meta->i18n_translation_rel_name() );
