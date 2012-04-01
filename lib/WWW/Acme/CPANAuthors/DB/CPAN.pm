package WWW::Acme::CPANAuthors::DB::CPAN;

use strict;
use warnings;
use base 'WWW::Acme::CPANAuthors::DB::Base';

sub dbname { 'cpan.db' }
sub schema { return <<'SCHEMA';
create table if not exists cpan_authors (
  pause_id text primary key not null,
  name text
);

create table if not exists mappings (
  pause_id text not null,
  category_id text not null
);

create table if not exists categories (
  category_id text primary key not null,
  category text,
  version text
);

create index if not exists mappings_pause_idx
  on mappings (pause_id);

create index if not exists mappings_category_idx
  on mappings (category_id);
SCHEMA
}

sub setup_and_register {
  my $self = shift;

  $self->setup;

  require WWW::Acme::CPANAuthors::CPAN::Mailrc;
  WWW::Acme::CPANAuthors::CPAN::Mailrc->register($self);

  require WWW::Acme::CPANAuthors::AcmeLibs;
  WWW::Acme::CPANAuthors::AcmeLibs->register($self);
}

sub get_listed_authors {
  my ($self, $categories) = @_;

  my $sql = "select pause_id, name from cpan_authors";
  if ($categories) {
    $categories = [$categories] unless ref $categories eq ref [];
    my $params = $self->in_params([map {lc $_} @$categories]);
    $sql .= " where pause_id in (select pause_id from mappings where category_id in ($params))";
  }
  $self->fetchall($sql);
}

sub get_listed_author_ids {
  my ($self, $categories) = @_;

  my $sql = "select distinct(pause_id) from mappings where";
  if ($categories) {
    $categories = [$categories] unless ref $categories eq ref [];
    my $params = $self->in_params([map {lc $_} @$categories]);
    $sql .= " category_id in ($params) and";
  }
  $sql .= " pause_id != ''";
  $self->fetchall_1($sql);
}

sub get_author_info {
  my ($self, $id) = @_;
  my %info;
  {
    my $row = $self->fetch('select name from cpan_authors where pause_id = ?', $id);
    return unless $row;
    $info{name} = $row->{name};
  }
  $info{listed} = $self->fetchall('select category, category_id from categories where category_id in (select category_id from mappings where pause_id = ?)', $id);
  \%info;
}

sub search_authors {
  my ($self, $part) = @_;

  $part = uc $part;
  $self->fetchall("select pause_id, name from cpan_authors where pause_id glob ?", "$part*");
}

sub get_category_ids {
  shift->fetchall_1('select category_id from categories');
}

sub count_acme_cpanauthors_modules {
  my $self = shift;
  $self->fetch_1('select count(*) from categories');
}

sub count_total_authors {
  my $self = shift;
  $self->fetch_1('select count(*) from cpan_authors');
}

sub count_listed_authors {
  my ($self, $categories) = @_;

  my $sql = "select category_id, count(distinct(pause_id)) as count from mappings where ";
  if ($categories) {
    my $params = $self->in_params($categories);
    $sql .= "category_id in ($params) and";
  }
  $sql .= " pause_id !='' group by category_id";
  $self->fetchall($sql);
}

sub get_categories {
  my $self = shift;

  $self->fetchall('select * from categories order by category_id');
}

sub register_authors {
  my ($self, $authors) = @_;

  $self->bulk('insert or replace into cpan_authors values (?,?)', $authors);
}

sub register_package {
  my ($self, $category_id, $package, $version, $authors) = @_;

  my $id = $self->fetch_1('select category_id from categories where category_id = ? and version = ?', $category_id, $version);
  unless ($id) {
    $self->do('insert or replace into categories values (?,?,?)', $category_id, $package, $version);
    $id = $self->dbh->sqlite_last_insert_rowid;
  }
  $self->txn(sub {
    $self->do('delete from mappings where category_id = ?', $category_id);
    $self->do('insert into mappings values (?,?)', $_, $category_id) for keys %$authors;
  });
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::DB::CPAN

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 count_acme_cpanauthors_modules
=head2 count_listed_authors
=head2 count_total_authors
=head2 dbname
=head2 get_author_info
=head2 get_categories
=head2 get_category_ids
=head2 get_listed_author_ids
=head2 get_listed_authors
=head2 register_authors
=head2 register_package
=head2 schema
=head2 search_authors
=head2 setup_and_register

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
