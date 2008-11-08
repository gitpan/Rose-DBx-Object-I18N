package DB::Object::I18N;

use strict;

use base qw/ Rose::DBx::Object::I18N / ;

use DB;

sub init_db {
    my $self = shift;

    DB->new_or_cached( @_ );
}

sub i18n_languages {
    my @languages = qw/ ru en ua /;

    wantarray ? @languages : \@languages;
}

=head1 AUTHOR

vti

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
