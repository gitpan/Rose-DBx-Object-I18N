package NewDB;

use DB;

sub new {
    my $class = shift;

    my $self = { db => DB->new };

    bless $self, $class;

    return $self;
}

sub db { shift->{ db } }

sub exists {
    my $self = shift;

    return -f $self->db->database && @{ $self->db->list_tables };
}

sub cleanup {
    my $self = shift;

    unlink $self->db->database;
}

sub init {
    my $self = shift;

    my $dbh = $self->db->retain_dbh;

    unless ( $self->exists ) {
        warn 'Creating new db...';

        $dbh->do( <<SQL );
CREATE TABLE `user` (
  `id` INTEGER PRIMARY KEY NOT NULL,
  `orig_lang` CHARACTER VARYING(2) NOT NULL,
  `name` CHARACTER VARYING(255) NOT NULL,
  UNIQUE (`name`)
);
SQL

        $dbh->do( <<SQL );
CREATE TABLE `user_i18n` (
  `i18nid` INTEGER PRIMARY KEY NOT NULL,
  `user_id` INTEGER NOT NULL,
  `lang` CHARACTER VARYING(2) NOT NULL,
  `signature` CHARACTER VARYING(255),
  `istran` TINYINT(1) NOT NULL DEFAULT 0
);
SQL
    }
}

=head1 AUTHOR

vti

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
