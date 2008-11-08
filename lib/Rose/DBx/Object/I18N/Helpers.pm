package Rose::DBx::Object::I18N::Helpers;

use strict;
use warnings;

use Rose::Object::MixIn();
our @ISA = qw(Rose::Object::MixIn);

__PACKAGE__->export_tag( all => [ qw(i18n_language) ] );

sub i18n_language {
    my ( $self ) = @_;

    my $lang;

    my $env_lang;
    ( $env_lang ) = ( $ENV{ LANG } =~ m/^(..)(?:_..\.)?/ ) if $ENV{ LANG };

    $lang = $env_lang;

    if ( !$lang && $self ) {
        $lang = $self->can( 'orig_lang' ) ? $self->orig_lang : undef;
    }

    return $lang;
}

=head1 COPYRIGHT & LICENSE

Copyright 2008 Viacheslav Tikhanovskii, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
