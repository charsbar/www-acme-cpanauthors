package WWW::Acme::CPANAuthors::DB::Base;

use strict;
use warnings;
use DBI;
use WWW::Acme::CPANAuthors::AppRoot;

sub url    {}
sub dbname {}
sub schema {}

sub new { my $class = shift; bless {@_}, $class }

sub setup {
  my $self = shift;
  my $dbh = $self->dbh;
  $dbh->begin_work;
  $dbh->do($_) for split /\n\n/, $self->schema;
  $dbh->commit;
}

sub dbfile {
  my $self = shift;
  unless ($self->{dbfile}) {
    my $dir = dir('db')->mkdir;
    $self->{dbfile} = file($dir, $self->dbname);
  }
  $self->{dbfile};
}

sub dbh {
  my $self = shift;
  unless ($self->{dbh} && $self->{dbh}->{Active}) {
    $self->{dbh} = DBI->connect("dbi:SQLite:".$self->dbfile,'','', {
      AutoCommit => 1,
      RaiseError => 1,
      PrintError => 0,
      ShowErrorStatement => 1,
      sqlite_use_immediate_transaction => 1,
    });
    if ($self->{profile}) {
      $self->profile($self->{profile});
    }
    if ($self->{trace}) {
      $self->trace($self->{trace});
    }
  }
  $self->{dbh};
}

sub profile {
  my ($self, $value) = @_;
  my $cb = ref $value ? $value :
           !$value    ? undef :
           sub {print STDERR "# $_[0]: $_[1]\n"};
  $self->{dbh}->sqlite_profile($cb);
}

sub trace {
  my ($self, $value) = @_;
  my $cb = ref $value ? $value :
           !$value    ? undef :
           sub {print STDERR "# $_[0]\n"};
  $self->{dbh}->sqlite_trace($cb);
}

sub explain {
  my $self = shift;
  return unless $self->{explain};
  my $plan = $self->dbh->selectall_arrayref("EXPLAIN QUERY PLAN ".shift, undef, @_);
  # print STDERR "i|o|f|detail\n" if @$plan;
  print STDERR (join '|', @{$_}) . "\n" for @$plan;
}

sub fetch {
  my $self = shift;
  $self->explain(@_);
  $self->dbh->selectrow_hashref(shift, undef, @_);
}

sub fetchall {
  my $self = shift;
  $self->explain(@_);
  my $rows = $self->dbh->selectall_arrayref(shift, {Slice => {}}, @_);
  wantarray ? @$rows : $rows;
}

sub fetchall_in_a_page {
  my $self = shift;
  my $opts = (ref $_[-1] eq ref {}) ? pop @_ : {limit => 100, page => 1};
  my $limit    = _num_or($opts->{limit}, 100);
  my $page     = _num_or($opts->{page}, 1);
  my $offset   = ($page - 1) * $limit;
  my $limit_ex = $limit + 1;

  my ($sql, @params) = @_;
  $sql .= " limit $limit_ex offset $offset";

  $self->explain($sql, @params);
  my $rows = $self->dbh->selectall_arrayref($sql, {Slice => {}}, @params);

  my $prev = $page > 1 ? $page - 1 : undef;
  my $next;
  if (@$rows == $limit_ex) {
    pop @$rows;
    $next = $page + 1;
  }

  return { rows => $rows, prev => $prev, next => $next };
}

sub _num_or {
  my ($num, $default) = @_;
  $num = '' unless defined $num;
  $num =~ tr/0-9//cd;
  $num ||= $default;
  $num;
}

sub fetch_1 {
  my $self = shift;
  $self->explain(@_);
  my ($col) = $self->dbh->selectrow_array(shift, undef, @_);
  return $col;
}

sub fetchall_1 {
  my $self = shift;
  $self->explain(@_);
  my $sth = $self->dbh->prepare(shift);
  $sth->execute(@_);
  $sth->bind_col(1, \my $val);
  my @vals;
  push @vals, $val while $sth->fetch;
  return wantarray ? @vals : \@vals;
}

sub do {
  my $self = shift;
  $self->explain(@_);
  $self->dbh->do(shift, undef, @_);
}

sub in_params {
  my $self = shift;
  my $dbh = $self->dbh;

  # Much better to use bind params if there's no limitation for the
  # num of bind params in sqlite... (SQLITE_MAX_VARIABLE_NUMBER)
  join ',', map { $dbh->quote($_) } (ref $_[0] eq ref [] ? @{$_[0]} : @_);
}

sub bulk {
  my ($self, $sql, $rows) = @_;

  my $dbh = $self->dbh;
  my $sth = $dbh->prepare($sql);

  my $ct = 0;
  $dbh->{AutoCommit} = 0;
  for (@$rows) {
    $sth->execute(@$_);
    $dbh->commit unless ++$ct % 1000;
  }
  $dbh->{AutoCommit} = 1;
}

sub txn {
  my ($self, $callback, @args) = @_;

  my $dbh = $self->dbh;
  $dbh->begin_work;
  eval { $callback->($self, @args) };
  warn $@ if $@;
  $@ ? $dbh->rollback : $dbh->commit;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::DB::Base

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 bulk
=head2 dbfile
=head2 dbh
=head2 dbname
=head2 do
=head2 explain
=head2 fetch
=head2 fetch_1
=head2 fetchall
=head2 fetchall_1
=head2 fetchall_in_a_page
=head2 in_params
=head2 new
=head2 profile
=head2 schema
=head2 setup
=head2 trace
=head2 txn
=head2 url

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
