package Rose::DBx::Object::I18N::Metadata;

use strict;
use warnings;

use base 'Rose::DB::Object::Metadata';

use Rose::Class::MakeMethods::Generic(
    scalar => [ qw/ i18n_static_rel_name i18n_translation_rel_name / ] );

=head1 COPYRIGHT & LICENSE

Copyright 2008 Viacheslav Tikhanovskii, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
