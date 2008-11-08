package Rose::DBx::Object::I18N;

use base qw/ Rose::DB::Object /;
require Carp;

use Hash::Merge 'merge';

use Rose::DB::Object::Constants qw(:all);
use Rose::DB::Constants qw(IN_TRANSACTION);

use Rose::DB::Object::Helpers qw/ has_loaded_related /;

use Rose::DBx::Object::I18N::Helpers ':all';

our $Debug = 0;

our $VERSION = 0.01;

=head1 NAME

Rose::DBx::Object::I18N - set of modules to deal with multilingual database

=head1 SYNOPSIS

    # create user with multilingual data
    my $u = User->new(
        name      => 'ppp',
        orig_lang => 'en',
        signature => 'hello'
    );
    $u->save();

    # load german translation
    $u->load( i18n => 'de' );
    $u->signature; # hello

    # retrieve available translations
    $u->i18n_available_translations; # undef

    # update translation
    $u->i18n->signature( 'hallo' );
    $u->save();
    $u->i18n_available_translations; # [ 'en' ]

    # update original
    $u->i18n( 'en' )->signature( 'hi' );
    $u->save();

    # check if original translation is loaded
    $u->is_original_loaded; # 1

    $u->i18n( 'de' );

    # delete loaded translation
    $u->delete_i18n();
    $u->i18n_available_translations; # undef
    $u->i18n( 'de' )->signature; # hi

=head1 DESCRIPTION

There are different ways to deal with multilingual problem. We will look at a
few of them.

=head2 Separate Data For Each Language

    articles
    +----+-----------+----------+-------+
    | id | author_id | language | title |
    +----+-----------+----------+-------+
    |  1 |         1 |       en |   foo |
    +----+-----------+----------+-------+
    |  2 |         1 |       de |   bar |
    +----+-----------+----------+-------+
    |  3 |         2 |       en |   foo |
    +----+-----------+----------+-------+

This is a easiest one to imagine. You have all data separated. If user wants
something in English just give him what he wants. There is no relation between
data, so if nothing is found in English there is no way how to know if there is
something in German, etc.

Also, the data that is shared between translations, like link, author id,
something else that can't be translated should be synchronized on every change
in other translations.

The good is the speed. No joins, no lookups in other tables, etc.

=head2 Static Data, Language Data, Translation Data

    articles
    +----+-----------+-------------------+
    | id | author_id | original_language |
    +----+-----------+-------------------+
    |  1 |         1 |                en |
    +----+-----------+-------------------+
    |  2 |         2 |                de |
    +----+-----------+-------------------+

    languages
    +------------+---------+----------+
    | article_id | i18n_id | language |
    +------------+---------+----------+
    |          1 |       1 |       en |
    +------------+---------+----------+
    |          1 |       2 |       de |
    +------------+---------+----------+
    |          2 |       3 |       de |
    +------------+---------+----------+

    i18n
    +----+-------+
    | id | title |
    +----+-------+
    |  1 |   foo |
    +----+-------+
    |  2 |   bar |
    +----+-------+
    |  3 |   foo |
    +----+-------+

Here we have three tables. One is for static data that is not going to be
translated, one is for languages that will hold what language is mapped to what
translation in translations table and the translation table, that holds
translatable information.

The problem is that there too many thins to do even for the one request. We
should make 3 joins and one IF statement in a join.

=head2 One Static, Many Translations

    articles
    +----+-----------+-------------------+
    | id | author_id | original_language |
    +----+-----------+-------------------+
    |  1 |         1 |                en |
    +----+-----------+-------------------+
    |  2 |         2 |                de |
    +----+-----------+-------------------+
    
    i18n
    +------------+----------+-------+
    | article_id | language | title |
    +------------+----------+-------+
    |          1 |       en |   foo |
    +------------+----------+-------+
    |          1 |       de |   bar |
    +------------+----------+-------+
    |          2 |       de |   foo |
    +------------+----------+-------+

Current approach for Rose::DBx::Object::I18N is to have two tables, one is for
the static data, and another for all translations.

=head2 Rose::DBx::Object::I18N

Plugging in Rose::DBx::Object::I18N is simply, instead of subclassing from
Rose::DB::Object use this namespace. But you must have two tables: one for the
Static data and another for Translation data.

    package DB::Object::I18N;

    use strict;

    use base qw/ Rose::DBx::Object::I18N / ;

    use DB;

    sub init_db {
        my $self = shift;

        DB->new_or_cached( @_ );
    }

    sub i18n_languages {
        my @languages = qw/ en de ru /;

        wantarray ? @languages : \@languages;
    }

Class for Static data can look like this.

    package User;
    
    use strict;
    
    use base qw(DB::Object::I18N::Static);

    use Rose::DBx::Object::I18N::Metadata;
    sub meta_class { 'Rose::DBx::Object::I18N::Metadata' };
    
    __PACKAGE__->meta->setup(
       table => 'user',
    
       columns => [
           qw/ id name /,
           orig_lang  => { type => 'i18n_language' }
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

       i18n_translation_rel_name => 'user_i18n'
    );

And class for Translation

    package UserI18N;
    
    use strict;
    
    use base qw/ DB::Object::I18N::Translation /;

    use Rose::DBx::Object::I18N::Metadata;
    sub meta_class { 'Rose::DBx::Object::I18N::Metadata' };
    
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
    
        foreign_keys => [
            user => {
                class       => 'User',
                key_columns => { user_id => 'id' },
                rel_type    => 'many to one',
            },
        ],

        i18n_static_rel_name => 'user'
    );

There is also I18N::Manager that can help you with selection i18n data.

    package User::Manager;
    
    use strict;
    
    use base 'Rose::DBx::Object::I18N::Manager';
    
    sub object_class { 'User' }
    
    __PACKAGE__->make_manager_methods( 'users' );

=head1 METHODS

=head2 new

Rose::DB::Object init method is overloaded, so you can use one of these
examples:

    my $u = User->new(
        name      => 'vti',
        orig_lang => 'en',
        user_i18n => { signature => 'hello' }
    );

    or

    my $u = User->new(
        name      => 'fake',
        orig_lang => 'en',
        signature => 'hello'
    );

    or even

    my $u = User->new(
        name      => 'foo',
        orig_lang => 'en'
    );

    and then

    $u->user_i18n( { signature => 'hello' } );

=cut

sub init {
    my ( $self ) = shift;

    my %params = @_;

    if ( my $rel_name = $self->meta->i18n_translation_rel_name() ) {
        my $i18n = {};

        while ( my ( $key, $val ) = each %params ) {
            $i18n->{ $key } = delete $params{ $key } unless $self->can( $key );
        }

        if ( %$i18n ) {
            $params{ $rel_name } ||= {};
            $params{ $rel_name } = { %$i18n, %{ $params{ $rel_name } } };
        }
    }

    $self->SUPER::init( %params );
}

=head2 save

CREATE

Data that is static is added to static table, then for each language
translatable data is added to translations table with a flag (istran) that there
is no translation.

UPDATE

If updating original language data update it and then synchronize with all
translations that are not translations (the data is the same, istran flag is 0)

If updating translation set istran to 1 and update all columns as usual.

=cut

sub save {
    my $self = shift;
    my %params = @_;

    if (my $rel_name = $self->meta->i18n_translation_rel_name()) {
        my $i18n_save = 0;
        #if ( !$self->has_loaded_related( $rel_name ) && $self->{ _i18n } ) {
        if ( $self->{ _i18n } ) {
            $i18n_save = 1;
        }

        $self->i18n->save() if $i18n_save && !$params{noi18n};
        #$self->i18n->save();
    }

    $self->SUPER::save(@_);
}

sub insert {
    my $self = shift;

    if ( my $rel_name = $self->meta->i18n_translation_rel_name() ) {
        die 'no languages provided' unless $self->i18n_languages;

        if ( $self->$rel_name ) {
            my $i18n = shift @{ $self->$rel_name };

            my $i18n_lang_column   = $i18n->_i18n_lang_column;
            my $i18n_istran_column = $i18n->_i18n_istran_column;

            my $add_method = "add_$rel_name";
            foreach my $lang ( @{ $self->i18n_languages } ) {
                $i18n->$i18n_lang_column( $lang );
                $i18n->$i18n_istran_column( 0 );
                $self->$add_method(
                    { map { $_ => $i18n->$_ } @{ $i18n->meta->column_names } }
                );
            }
        } else {
            my ( $rel ) = grep { $_->name eq $rel_name } $self->meta->relationships;

            my ( $i18n_lang ) = grep { $_->type eq 'i18n_language' }
              $rel->foreign_class->meta->columns;
            my $i18n_lang_column = $i18n_lang->name;

            my ( $i18n_istran ) = grep { $_->type eq 'i18n_is_translation' }
              $rel->foreign_class->meta->columns;
            my $i18n_istran_column = $i18n_istran->name;

            $self->$rel_name(
                map {
                    { $i18n_lang_column => $_, $i18n_istran_column => 0 }
                  } $self->i18n_languages
            );
        }
    }

    $self->SUPER::insert( @_ );
}

sub update {
    my $self = shift;

    if ( $self->meta->i18n_static_rel_name() ) {
        my $parent = $self->_i18n_parent;

        my $orig_lang_column   = $parent->_i18n_lang_column;
        my $i18n_lang_column   = $self->_i18n_lang_column;
        my $i18n_istran_column = $self->_i18n_istran_column;

        if ( $parent->$orig_lang_column eq $self->$i18n_lang_column ) {
            foreach my $i18n ( $parent->not_translated_i18n() ) {
                $i18n->_i18n_sync_with( $self );
            }
        } else {
            $self->$i18n_istran_column( 1 );
        }
    }

    $self->SUPER::update( @_ );
}

=head2 load

When you want to load default language ($ENV{LANG} or original) just load as you
always do:

    $u = User->new( id => 1 );
    $u->load();

When you want to load en translation:

    $u = User->new( id => 1 );
    $u->load( i18n => 'en' );

=head2 i18n PARAM

Returns preloaded i18n object or, if the last was not found, preloads it taking the
default language or language that is provided as a parameter.

    $u = User->new( id => 1 );
    # let's assume that the original language is English ('en').
    $u->load();

    $u->i18n->title;       # title is in English
    $u->i18n('de')->title; # title is in German
    $u->i18n('en')->title; # title is back in English

=cut

sub i18n {
    my ( $self, $i18n ) = @_;

    my $rel_name = $self->meta->i18n_translation_rel_name();

    return unless $rel_name;

    return $self->{ _i18n } if !$i18n && $self->{ _i18n };

    if ( !$i18n && $self->has_loaded_related( $rel_name ) ) {
        $self->{ _i18n } = $self->$rel_name->[ 0 ];
    } else {
        $self->_load_i18n( i18n => $i18n );
    }

    return $self->{ _i18n };
}

=head2 i18n_available_translations

Returns array reference of another available translations.

=cut

sub i18n_available_translations {
    my $self = shift;

    my $rel_name = $self->meta->i18n_translation_rel_name();
    return unless $rel_name;

    my $method = "find_$rel_name";

    unless ( $self->i18n_is_loaded() ) {
        $self->error( "first do i18n()" );
        $self->meta->handle_error( $self );
        return;
    }

    my $orig_lang_column   = $self->_i18n_lang_column;
    my $i18n_lang_column   = $self->i18n->_i18n_lang_column;
    my $i18n_istran_column = $self->i18n->_i18n_istran_column;

    my $orig_lang = $self->$orig_lang_column;
    my $lang      = $self->i18n->$i18n_lang_column;

    my $subquery;
    if ( $self->i18n_is_original_loaded() ) {
        $subquery = [ $i18n_istran_column => 1, ];
    } else {
        $subquery = [
            or => [
                $i18n_istran_column => 1,
                $i18n_lang_column   => $orig_lang
            ]
        ];
    }

    my $i18n = $self->$method(
        query => [
            $i18n_lang_column => { ne => $lang },
            @$subquery
        ],
        select => $i18n_lang_column
    );

    return [ map { $_->$i18n_lang_column } @$i18n ];
}

=head2 i18n_is_original_loaded

Returns if loaded translation is original.

=cut

sub i18n_is_original_loaded {
    my $self = shift;

    my $orig_lang_column   = $self->_i18n_lang_column;
    my $i18n_lang_column   = $self->i18n->_i18n_lang_column;
    my $i18n_istran_column = $self->i18n->_i18n_istran_column;

    return $self->$orig_lang_column eq $self->i18n->$i18n_lang_column
      || $self->i18n->$i18n_istran_column == 0 ? 1 : 0;
}

=head2 not_translated_i18n

Return array reference of languages that have no translation.

=head2 delete_i18n

Delete currently loaded translation and loads original.

=cut

sub delete_i18n {
    my $self = shift;

    return if $self->i18n_is_original_loaded();

    my $orig_lang_column   = $self->_i18n_lang_column;
    my $i18n_lang_column   = $self->i18n->_i18n_lang_column;
    my $i18n_istran_column = $self->i18n->_i18n_istran_column;

    return unless $self->i18n->$i18n_istran_column;

    my $translation_rel_name = $self->meta->i18n_translation_rel_name();
    my $method               = "find_$translation_rel_name";

    my $original_i18n = $self->$method(
        query => [
            $i18n_istran_column => 0,
            $i18n_lang_column   => $self->$orig_lang_column
        ]
    )->[ 0 ];

    $self->i18n->$i18n_istran_column( 0 );
    $self->i18n->_i18n_sync_with( $original_i18n );
}

=head2 Rose::DBx::Object::I18N::Manager

On selection there is only one join, no need to do any logic selection, because
we have all data ready for selection at the right place. If there was no
translation, anyway data will be there, it will be original, because no
translation was updated.

get_objects method is overloaded, so you don't have to provide query with the
language selection and table to join, just use is transparently:

    User::Manager->get_objects( i18n => 'en' );

=cut

sub _load_i18n {
    my $self = shift;
    my %args = @_;

    my $language = $args{ i18n } || $self->i18n_language();

    my $rel_name = $self->meta->i18n_translation_rel_name();

    my $meta = $self->meta;

    my ( $rel ) = grep { $_->name eq $rel_name } $self->meta->relationships;
    my ( $i18n_lang ) =
      grep { $_->type eq 'i18n_language' } $rel->foreign_class->meta->columns;
    my $i18n_lang_column = $i18n_lang->name;

    my $method = "find_$rel_name";
    my $i18n = $self->$method( [ $i18n_lang_column => $language ] );

    my $loaded_ok = $i18n ? $i18n->[ 0 ] ? 1 : 0 : 0;

    unless ( $loaded_ok ) {
        my $speculative =
          exists $args{ 'speculative' }
          ? $args{ 'speculative' }
          : $meta->default_load_speculative;

        unless ( $speculative ) {
            $self->error( "load_i18n() - can't find $language translation" );
            $meta->handle_error( $self );
        }

        return 0;
    }

    $self->{ _i18n } = $i18n->[ 0 ];

    return 1;
}

sub not_translated_i18n {
    my $self = shift;

    my $translation_rel_name = $self->meta->i18n_translation_rel_name();
    my $method               = "find_$translation_rel_name";

    my $orig_lang_column   = $self->_i18n_lang_column;
    my $i18n_lang_column   = $self->i18n->_i18n_lang_column;
    my $i18n_istran_column = $self->i18n->_i18n_istran_column;

    my @i18n = $self->$method(
        query => [
            $i18n_istran_column => 0,
            $i18n_lang_column   => { ne => $self->$orig_lang_column }
        ]
    );

    return wantarray ? @i18n : \@i18n;
}

sub _i18n_parent {
    my $self = shift;

    my $rel_name = $self->meta->i18n_static_rel_name();
    return $self->$rel_name;
}

sub _i18n_sync_with {
    my $self = shift;
    my ( $from ) = @_;

    my $i18n_lang_column   = $self->_i18n_lang_column;
    my $i18n_istran_column = $self->_i18n_istran_column;

    my ( $pk ) = $self->meta->primary_key_column_names;

    my @columns =
      grep { $_ !~ m/(?:$pk|$i18n_istran_column|$i18n_lang_column)/ }
      $self->meta->column_names();

    my @debug;
    foreach my $column ( @columns ) {
        my $old = $self->$column;
        $self->$column( $from->$column );
    }
    $self->SUPER::update();
}

sub i18n_is_loaded
{
    my $self = shift;

    my $rel_name = $self->meta->i18n_translation_rel_name();

    return $self->has_loaded_related( $rel_name ) || $self->{ _i18n } ? 1 : 0;
}

sub _i18n_istran_column {
    my $self = shift;

    my ( $column ) =
      grep { $_->type eq 'i18n_is_translation' } @{ $self->meta->columns };

    return $column->name;
}

sub _i18n_lang_column {
    my $self = shift;

    my ( $column ) =
      grep { $_->type eq 'i18n_language' } @{ $self->meta->columns };

    return $column->name;
}

use constant LAZY_LOADED_KEY => 
  Rose::DB::Object::Util::lazy_column_values_loaded_key();

sub load
{
  my($self) = $_[0]; # XXX: Must maintain alias to actual "self" object arg

  my %args = (self => @_); # faster than @_[1 .. $#_];

  $self->SUPER::load( %args ) if $self->meta->i18n_static_rel_name();

  my $db  = $self->db  or return 0;
  my $dbh = $self->dbh or return 0;

  my $meta = $self->meta;

  my $prepare_cached = 
    exists $args{'prepare_cached'} ? $args{'prepare_cached'} :
    $meta->dbi_prepare_cached;

  local $self->{STATE_SAVING()} = 1;

  my(@key_columns, @key_methods, @key_values);

  my $null_key  = 0;
  my $found_key = 0;

  if ( my $i18n = (delete $args{ i18n }) ) {
    my $rel_name = $self->meta->i18n_translation_rel_name();
    my $new_args = merge {
        query => ["$rel_name.lang" => $i18n],
        with => [ $rel_name ]
    }, \%args;

    %args = %$new_args;
  }

  if(my $key = delete $args{'use_key'})
  {
    my @uk = grep { $_->name eq $key } $meta->unique_keys;

    if(@uk == 1)
    {
      my $defined = 0;
      @key_columns = $uk[0]->column_names;
      @key_methods = map { $meta->column_accessor_method_name($_) } @key_columns;
      @key_values  = map { $defined++ if(defined $_); $_ } 
                     map { $self->$_() } @key_methods;

      unless($defined)
      {
        $self->error("Could not load() based on key '$key' - column(s) have undefined values");
        $meta->handle_error($self);
        return undef;
      }

      if(@key_values != $defined)
      {
        $null_key = 1;
      }
    }
    else { Carp::croak "No unique key named '$key' is defined in ", ref($self) }
  }
  else
  {
    @key_columns = $meta->primary_key_column_names;
    @key_methods = $meta->primary_key_column_accessor_names;
    @key_values  = grep { defined } map { $self->$_() } @key_methods;

    unless(@key_values == @key_columns)
    {
      my $alt_columns;

      # Prefer unique keys where we have defined values for all
      # key columns, but fall back to the first unique key found 
      # where we have at least one defined value.
      foreach my $cols ($meta->unique_keys_column_names)
      {
        my $defined = 0;
        @key_columns = @$cols;
        @key_methods = map { $meta->column_accessor_method_name($_) } @key_columns;
        @key_values  = map { $defined++ if(defined $_); $_ } 
                       map { $self->$_() } @key_methods;

        if($defined == @key_columns)
        {
          $found_key = 1;
          last;
        }

        $alt_columns ||= $cols  if($defined);
      }

      if(!$found_key && $alt_columns)
      {
        @key_columns = @$alt_columns;
        @key_methods = map { $meta->column_accessor_method_name($_) }  @key_columns;
        @key_values  = map { $self->$_() } @key_methods;
        $null_key    = 1;
        $found_key   = 1;
      }

      unless($found_key)
      {
        @key_columns = $meta->primary_key_column_names;

        my $e = 
          Rose::DB::Object::Exception->new(
            message => "Cannot load " . ref($self) . " without a primary key (" .
                       join(', ', @key_columns) . ') with ' .
                       (@key_columns > 1 ? 'non-null values in all columns' : 
                                           'a non-null value') .
                       ' or another unique key with at least one non-null value.',
            code => EXCEPTION_CODE_NO_KEY);

        $self->error($e);
        $meta->handle_error($self);
        return 0;
      }
    }
  }

  my $has_lazy_columns = $args{'nonlazy'} ? 0 : $meta->has_lazy_columns;
  my $column_names;

  if($has_lazy_columns)
  {
    $column_names = $meta->nonlazy_column_names;
    $self->{LAZY_LOADED_KEY()} = {};
  }
  else
  {
    $column_names = $meta->column_names;
  }

  #
  # Handle sub-object load in separate code path
  #

  if(my $with = $args{'with'})
  {
    my $mgr_class = $args{'manager_class'} || 'Rose::DB::Object::Manager';
    my %query;

    @query{map { "t1.$_" } @key_columns} = @key_values;


    $args{query} ||= [];

    %query = ( @{ $args{query} }, %query );

    #use Data::Dumper;
    #print Dumper $args{query};
    #print Dumper \%query;

    my $objects;

    eval
    {
      $objects = 
        $mgr_class->get_objects(object_class   => ref $self,
                                db             => $db,
                                query          => [ %query ],
                                with_objects   => $with,
                                multi_many_ok  => 1,
                                nonlazy        => $args{'nonlazy'},
                                inject_results => $args{'inject_results'},
                                (exists $args{'prepare_cached'} ?
                                (prepare_cached =>  $args{'prepare_cached'}) : 
                                ()))
          or Carp::confess $mgr_class->error;

      if(@$objects > 1)
      {
        die "Found ", @$objects, " objects instead of one";
      }
    };

    if($@)
    {
      $self->error("load(with => ...) - $@");
      $meta->handle_error($self);
      return undef;
    }

    if(@$objects > 0)
    {
      # Sneaky init by object replacement
      $self = $_[0] = $objects->[0];

      # Init by copying attributes (broken; need to do fks and relationships too)
      #my $methods = $meta->column_mutator_method_names;
      #my $object  = $objects->[0];
      #
      #local $self->{STATE_LOADING()}  = 1;
      #local $object->{STATE_SAVING()} = 1;
      #
      #foreach my $method (@$methods)
      #{
      #  $self->$method($object->$method());
      #}
    }
    else
    {
      no warnings;
      $self->error("No such " . ref($self) . ' where ' . 
                   join(', ', @key_columns) . ' = ' . join(', ', @key_values));
      $self->{'not_found'} = 1;

      $self->{STATE_IN_DB()} = 0;

      my $speculative = 
        exists $args{'speculative'} ? $args{'speculative'} :     
        $meta->default_load_speculative;

      unless($speculative)
      {
        $meta->handle_error($self);
      }

      return 0;
    }

    $self->{STATE_IN_DB()} = 1;
    $self->{LOADED_FROM_DRIVER()} = $db->{'driver'};
    $self->{MODIFIED_COLUMNS()} = {};
    return $self || 1;
  }

  #
  # Handle normal load
  #

  my $loaded_ok;

  $self->{'not_found'} = 0;

  eval
  {
    local $self->{STATE_LOADING()} = 1;
    local $dbh->{'RaiseError'} = 1;

    my($sql, $sth);

    if($null_key)
    {
      if($has_lazy_columns)
      {
        $sql = $meta->load_sql_with_null_key(\@key_columns, \@key_values, $db);
      }
      else
      {
        $sql = $meta->load_all_sql_with_null_key(\@key_columns, \@key_values, $db);
      }
    }
    else
    {
      if($has_lazy_columns)
      {
        $sql = $meta->load_sql(\@key_columns, $db);
      }
      else
      {
        $sql = $meta->load_all_sql(\@key_columns, $db);
      }
    }

    # $meta->prepare_select_options (defunct)
    $sth = $prepare_cached ? $dbh->prepare_cached($sql, undef, 3) : 
                             $dbh->prepare($sql);

    $Debug && warn "$sql - bind params: ", join(', ', grep { defined } @key_values), "\n";
    $sth->execute(grep { defined } @key_values);

    my %row;

    $sth->bind_columns(undef, \@row{@$column_names});

    $loaded_ok = defined $sth->fetch;

    # The load() query shouldn't find more than one row anyway, 
    # but DBD::SQLite demands this :-/
    $sth->finish;

    if($loaded_ok)
    {
      my $methods = $meta->column_mutator_method_names_hash;

      # Empty existing object?
      #%$self = (db => $self->db, meta => $meta, STATE_LOADING() => 1);

      foreach my $name (@$column_names)
      {
        my $method = $methods->{$name};
        $self->$method($row{$name});
      }

      # Sneaky init by object replacement
      #my $object = (ref $self)->new(db => $self->db);
      #
      #foreach my $name (@$column_names)
      #{
      #  my $method = $methods->{$name};
      #  $object->$method($row{$name});
      #}
      #
      #$self = $_[0] = $object;
    }
    else
    {
      no warnings;
      $self->error("No such " . ref($self) . ' where ' . 
                   join(', ', @key_columns) . ' = ' . join(', ', @key_values));
      $self->{'not_found'} = 1;
      $self->{STATE_IN_DB()} = 0;
    }
  };

  if($@)
  {
    $self->error("load() - $@");
    $meta->handle_error($self);
    return undef;
  }

  unless($loaded_ok)
  {
    my $speculative = 
      exists $args{'speculative'} ? $args{'speculative'} :     
      $meta->default_load_speculative;

    unless($speculative)
    {
      $meta->handle_error($self);
    }

    return 0;
  }

  $self->{STATE_IN_DB()} = 1;
  $self->{LOADED_FROM_DRIVER()} = $db->{'driver'};
  $self->{MODIFIED_COLUMNS()} = {};
  return $self || 1;
}

=head1 COPYRIGHT & LICENSE

Copyright 2008 Viacheslav Tikhanovskii, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
