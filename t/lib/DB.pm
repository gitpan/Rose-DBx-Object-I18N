package DB;

use strict;
use warnings;

use base qw(Rose::DB);

use File::Spec;

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db(
    driver   => 'sqlite',
    database => File::Spec->catfile( File::Spec->tmpdir, 'rose-i18n.db' ),
    post_connect_sql =>
      [ 'PRAGMA synchronous = OFF', 'PRAGMA temp_store = MEMORY', ],
);

=head1 AUTHOR

vti

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

