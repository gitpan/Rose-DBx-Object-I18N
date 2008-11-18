#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite is required to run this test" if $@;

plan 'tests' => 1;

use lib 't/lib';

use NewDB;

my $db = NewDB->new();

$db->cleanup();

ok( ! -f $db->db->database );
