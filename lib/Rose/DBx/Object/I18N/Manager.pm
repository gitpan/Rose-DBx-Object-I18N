package Rose::DBx::Object::I18N::Manager;

use strict;
use warnings;

use base 'Rose::DB::Object::Manager';

use Rose::DBx::Object::I18N::Helpers ':all';

use Hash::Merge 'merge';

sub get_objects {
    my $class = shift;
    my %args  = @_;

    if ( my $language = (delete $args{ i18n } || $class->i18n_language()) ) {
        my $rel_name = $class->object_class->meta->i18n_translation_rel_name();

        my ( $rel ) = grep { $_->name => $rel_name }
          $class->object_class->meta->relationships;

        my ( $i18n_lang ) = grep { $_->type eq 'i18n_language' }
          $rel->foreign_class->meta->columns;
        my $i18n_lang_column = $i18n_lang->name;

        my $new_args = merge {
            query        => [ "$rel_name.$i18n_lang_column" => $language ],
            with_objects => [ $rel_name ]
          },
          \%args;

        %args = %$new_args;
    }

    $class->SUPER::get_objects( %args );
}

=head1 COPYRIGHT & LICENSE

Copyright 2008 Viacheslav Tikhanovskii, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
