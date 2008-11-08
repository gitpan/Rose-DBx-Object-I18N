package UserI18N;

use strict;

use base qw/ DB::Object::I18N /;

use Metadata;
sub meta_class { 'Metadata' }

__PACKAGE__->meta->setup(
    table => 'user_i18n',

    columns => [
        qw/
          i18nid
          user_id
          signature
          /,
      lang => { type => 'i18n_language' },
      istran => { type => 'i18n_is_translation' }
    ],

    primary_key_columns => [ 'i18nid' ],

    relationships => [
        user => {
            class       => 'User',
            key_columns => { user_id => 'id' },
            type        => 'many to one',
        },
    ],

    i18n_static_rel_name => 'user'
);

=head1 AUTHOR

vti

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
