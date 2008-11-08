#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Rose::DBx::Object::I18N' );
}

diag( "Testing Rose::DBx::Object::I18N $Rose::DBx::Object::I18N::VERSION, Perl $], $^X" );
