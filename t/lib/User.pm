package User;

use strict;

use base qw(DB::Object::I18N);

use Metadata;
sub meta_class { 'Metadata' };

__PACKAGE__->meta->setup(
   table => 'user',

   columns => [
       qw/ id name /,
       orig_lang => { type => 'i18n_language' }
   ],

   primary_key_columns => [ qw/ id / ],

   unique_key => [ qw/ name / ],

   relationships => [
       user_i18n => {
           type       => 'one to many',
           class      => 'UserI18N',
           column_map => { id => 'user_id' }
       }
   ],

   i18n_translation_rel_name => 'user_i18n',
);

=head1 AUTHOR

vti

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
