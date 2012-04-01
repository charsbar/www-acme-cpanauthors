package WWW::Acme::CPANAuthors::DB::Uploads;

use strict;
use warnings;
use base 'WWW::Acme::CPANAuthors::DB::Base';

sub url { 'http://devel.cpantesters.org/uploads/uploads.db.gz' }
sub dbname { 'uploads.db' }
sub schema { return <<'SCHEMA';
create table if not exists uploads (
  type text,
  author text,
  dist text,
  version text,
  filename text,
  released int
);
SCHEMA
}

sub add_index {
  my $self = shift;
  $self->do('create index if not exists author_idx on uploads (author)');
  $self->do('create index if not exists dist_idx on uploads (dist)');
}

sub dists_by {
  my ($self, $id) = @_;

  $self->fetchall('select dist, version, released from (select * from uploads where author = ? and type <> "backpan") group by dist order by dist, released desc', $id);
}

sub acme_cpanauthors_dists {
  my $self = shift;
  my $rows = $self->fetchall('select dist, version, released from uploads where dist like "Acme-CPANAuthors-%" and type <> "backpan" group by dist order by released desc');

  my @dists;
  for my $row (@$rows) {
    next if $row->{dist} =~ /^Acme\-CPANAuthors\-(Search|Not)/;
    push @dists, $row;
  }
  return \@dists;
}

sub count_contributed_authors {
  my ($self, @authors) = @_;

  my $sql = "select count(distinct(author)) from uploads where";
  if (@authors) {
    my $params = $self->in_params(@authors);
    $sql .= " author in ($params) and";
  }
  $sql .= " type <> 'backpan'";

  $self->fetch_1($sql);
}

sub count_active_authors {
  my ($self, @authors) = @_;

  my $sql = "select count(distinct(author)) from uploads where ";
  if (@authors) {
    my $params = $self->in_params(@authors);
    $sql .= " author in ($params) and ";
  }
  $sql .= "released > ? and type <> 'backpan'";
  $self->fetch_1($sql, time - int(86400 * 365.25));
}

sub count_dists_by {
  my ($self, $authors) = @_;

  my $sql = "select author, count(distinct(dist)) as count from uploads where";
  if ($authors) {
    my $params = $self->in_params($authors);
    $sql .= " author in ($params) and";
  }
  $sql .= " type <> 'backpan' group by author";
  $self->fetchall($sql);
}

sub count_recent_dists_by {
  my ($self, $authors) = @_;

  my $sql = "select author, count(distinct(dist)) as count from uploads where released > ?";
  if ($authors) {
    my $params = $self->in_params($authors);
    $sql .= " and author in ($params)";
  }
  $sql .= " and type <> 'backpan' group by author";
  $self->fetchall($sql, time - int(86400 * 365.25));
}

sub count_total_dists_by {
  my ($self, $authors) = @_;

  my $sql = "select count(distinct(dist)) from uploads where";
  if ($authors) {
    my $params = $self->in_params($authors);
    $sql .= " author in ($params) and";
  }
  $sql .= " type <> 'backpan'";
  $self->fetch_1($sql);
}

sub count_total_recent_dists_by {
  my ($self, $authors) = @_;

  my $sql = "select count(distinct(dist)) from uploads where released > ?";
  if ($authors) {
    my $params = $self->in_params($authors);
    $sql .= " and author in ($params)";
  }
  $sql .= " and type <> 'backpan'";
  $self->fetch_1($sql, time - int(86400 * 365.25));
}

sub count_dists_per_author {
  my $self = shift;
  $self->fetchall("select count(u.author) as authors, u.dists as dists from (select author, count(distinct(dist)) as dists from uploads where type <> 'backpan' group by author) as u group by u.dists");
}

sub count_dists_per_year {
  my $self = shift;
  $self->fetchall("select strftime('%Y', datetime(released, 'unixepoch')) as year, count(distinct(dist)) as dists from uploads group by year");
}

sub get_latest_dist {
  my ($self, $name) = @_;
  $self->fetch("select * from uploads where dist = ? and type <> 'backpan' order by released desc limit 1", $name);
}

sub search_dists {
  my ($self, $name) = @_;
  $self->fetchall("select distinct(dist) from uploads where dist like ?", $name."%");
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::DB::Uploads

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 acme_cpanauthors_dists
=head2 add_index
=head2 count_active_authors
=head2 count_contributed_authors
=head2 count_dists_by
=head2 count_dists_per_author
=head2 count_dists_per_year
=head2 count_recent_dists_by
=head2 count_total_dists_by
=head2 count_total_recent_dists_by
=head2 dbname
=head2 dists_by
=head2 get_latest_dist
=head2 schema
=head2 search_dists
=head2 url

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
