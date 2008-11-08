package User::Manager;

use strict;

use base 'Rose::DBx::Object::I18N::Manager';

sub object_class { 'User' }

__PACKAGE__->make_manager_methods( 'users' );

=head1 AUTHOR

vti

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
