package Metadata;

use strict;
use warnings;

use base 'Rose::DBx::Object::I18N::Metadata';

__PACKAGE__->column_type_class(
    i18n_language =>
        'Rose::DBx::Object::I18N::Metadata::Column::Language',
    i18n_is_translation =>
        'Rose::DBx::Object::I18N::Metadata::Column::IsTranslation'
);

1;
