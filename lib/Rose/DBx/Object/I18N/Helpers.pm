package Rose::DBx::Object::I18N::Helpers;

use strict;
use warnings;

use Rose::Object::MixIn();
our @ISA = qw(Rose::Object::MixIn);

__PACKAGE__->export_tag(all => [qw(i18n_language)]);

sub i18n_language {
    my ($self) = @_;

    my $lang = $ENV{RDBO_I18N_LANG};

    if (!$lang && $self) {
        unless ( $self->can('object_class') ) {
            my $i18n_lang_column = $self->_i18n_lang_column;
            $lang = $self->$i18n_lang_column;
        }
    }

    return $lang;
}

=head1 COPYRIGHT & LICENSE

Copyright 2008 Viacheslav Tikhanovskii, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
