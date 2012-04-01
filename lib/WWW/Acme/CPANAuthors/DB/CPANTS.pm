package WWW::Acme::CPANAuthors::DB::CPANTS;

use strict;
use warnings;
use base 'WWW::Acme::CPANAuthors::DB::Base';
use WWW::Acme::CPANAuthors::Kwalitee;

# -- settings ----------------------------------------------------

sub dbname { 'cpants_with_history.db' }
sub url { 'http://cpants.charsbar.org/static/cpants_with_history.db.gz' }
sub schema {
  require WWW::Acme::CPANAuthors::DB::CPANTS::Schema;
  WWW::Acme::CPANAuthors::DB::CPANTS::Schema->schema;
}

sub add_index {
  my $self = shift;

  # should fix Module::CPANTS::ProcessCPAN
  $self->do('create index if not exists error_dist_key on error (dist)');
  $self->do('create index if not exists history_author_author_key on history_author (author)');
  $self->do('create index if not exists history_dist_dist_key on history_dist (dist)');
  $self->do('create index if not exists kwalitee_dist_key on kwalitee (dist)');
}

# -- pages -------------------------------------------------------

# XXX: use less '*'s for better performance
# XXX: but don't try to get rid of them all to keep the code simple

# - Page::Author -
sub get_author_kwalitee {
  my ($self, $id) = @_;
  $self->fetch("select * from author where pauseid = ?", uc $id);
}

sub get_dist_kwalitee_list {
  my ($self, $dists) = @_;

  my $params = $self->in_params($dists);
  $self->fetchall("select kwalitee.*, dist.dist from dist join kwalitee on kwalitee.dist = dist.id where dist.dist in ($params)");
}

# - Page::Author::Chart -

sub get_author_history {
  my ($self, $id) = @_;
  $self->fetchall("select history_author.*, date(run.date) as date from history_author join run on history_author.run = run.id where author = (select id from author where pauseid = ?)", uc $id);
}

# - Page::For, Page::Modules, Page::YapcAsia -

sub get_author_kwalitee_list {
  my ($self, $ids) = @_;

  my $params = $self->in_params($ids);

  $self->fetchall("select * from author where pauseid in ($params) order by pauseid");
}

# - Page::Dist::* -

sub get_dist {
  my ($self, $name) = @_;

  $self->fetch("select dist.*, author.name as author_name, author.pauseid as author_pauseid from dist join author on dist.author = author.id where dist = ?", $name);
}

# - Page::Dist::Overview -

sub get_dist_kwalitee_by_id {
  my ($self, $id) = @_;

  $self->fetch("select * from kwalitee where dist = ?", $id);
}

# - Page::Dist::Chart -

sub get_dist_history {
  my ($self, $name) = @_;
  $self->fetchall("select history_dist.*, date(run.date) as date from history_dist join run on history_dist.run = run.id where dist = (select id from dist where dist = ?)", $name);
}

# - Page::Dist::Metadata -

sub get_dist_errors_by_id {
  my ($self, $id) = @_;

  # needs to handle dual life modules
  $self->fetch("select * from error where dist = ?", $id);
}

# - Page::Dist::Prereq

sub get_dist_prereqs_by_id {
  my ($self, $id) = @_;

  # false positives (by deprecation/monkey patch) may be slipped in.
  $self->fetchall("select prereq.*, (count(prereq.requires) - 1) as is_dual, dist.dist as dist_name, dist.version as dist_version, kwalitee.kwalitee as kwalitee from prereq join modules on prereq.requires = modules.module, dist on dist.id = modules.dist, kwalitee on kwalitee.dist = dist.id where prereq.dist = ? group by prereq.requires order by prereq.requires, dist.released desc", $id);
}

sub get_dist_uses_by_id {
  my ($self, $id) = @_;

  # needs to handle dual life modules
  $self->fetchall("select uses.*, dist.dist as dist_name, (count(uses.module) - 1) as is_dual from uses left join modules on modules.module = uses.module left join dist on dist.id = modules.dist where uses.dist = ? group by uses.module order by uses.module, dist.released desc", $id);
}

# - Page::Dist::Provides -

sub get_dist_modules_by_id {
  my ($self, $id) = @_;
  $self->fetchall("select * from modules where dist = ?", $id);
}

# - Page::Dist::UsedBy

sub get_dependent_dists_by_id {
  my ($self, $id) = @_;
  $self->fetchall("select dist.dist as dist, author.name as author_name, author.pauseid as author_pauseid, kwalitee.kwalitee as kwalitee from dist join author on author.id = dist.author, kwalitee on kwalitee.dist = dist.id where dist.id in (select prereq.dist from prereq where prereq.in_dist = ?)", $id);
}

# -- ranking ------------------------------------------------------

sub get_most_kwalitative_authors {
  my ($self, $opts) = @_;
  $opts ||= {};
  $opts->{limit} ||= 100;
  my $sql = "select * from author where (rank between 1 and $opts->{limit})";
  $sql .= ($opts->{liga} || 'more') eq 'more'
            ? " and num_dists >= 5"
            : " and (num_dists between 1 and 4)";
  $sql .= " order by rank, pauseid";
  $self->fetchall($sql);
}

sub get_most_kwalitative_dists {
  my $self = shift;
  $self->fetchall("select dist.dist as dist, author.pauseid as pauseid, k.kwalitee as kwalitee from (select kwalitee.dist, kwalitee.kwalitee from kwalitee where kwalitee.kwalitee = (select max(kwalitee.kwalitee) from kwalitee)) as k join dist on dist.id = k.dist join author on author.id = dist.author order by dist.dist");
}

sub get_authors_by_rank {
  my ($self, $opts) = @_;
  my $sql = "select * from author where";
  $sql .= ($opts->{liga} || 'more') eq 'more'
            ? " num_dists >= 5"
            : " (num_dists between 1 and 4)";

  $sql .= " order by average_kwalitee desc, num_dists desc, pauseid";

  $self->fetchall_in_a_page($sql, $opts);
}

# -- kwalitee -----------------------------------------------------

sub get_failing_dists { 
  my ($self, $metric, $opts) = @_;
  unless (is_valid_metric($metric)) {
    warn "requires a valid metric";
    return;
  }
  $opts ||= {};
  my $page = $opts->{page} || 1;
  my $limit = 100;
  my $offset = $limit * ($page - 1);
  $self->fetchall_1("select dist from dist where id in (select dist from kwalitee where $metric = 0) order by dist limit $limit offset $offset");
}

# -- search -------------------------------------------------------

sub search_dists {
  my ($self, $term) = @_;
  $self->fetchall_1("select dist from dist where dist like ? order by dist", "%$term%");
}

# -- graphs -------------------------------------------------------

sub get_kwalitee_overview {
  my $self = shift;

  # valid as long as each metric has 1 or 0
  my @sums;
  for my $metric (kwalitee_metrics()) {
    my $name = $metric->{name};
    push @sums, "sum($name) as $name";
  }
  $self->fetch("select count(*) as total, ".join(',',@sums)." from kwalitee");
}

sub count_kwalitee_dists {
  my $self = shift;

  my @names = map {$_->{name}} grep {!$_->{is_experimental}} kwalitee_metrics();

  $self->fetchall("select count(k.dist) as count, k.num as score from (select dist, (".join('+', @names).") as num from kwalitee) as k group by k.num");
}

# might be better to use the ones from ::DB::Uploads for these two
# (i.e. with more authoritative data, not from a local mirror)

sub count_dists_per_author {
  my $self = shift;

  $self->fetchall("select num_dists, count(num_dists) as count from author where num_dists > 0 group by num_dists");
}

sub count_dists_per_year {
  my $self = shift;

  $self->fetchall("select strftime('%Y', released) as year, count(*) as count from dist group by year");
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::DB::CPANTS

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 add_index
=head2 count_dists_per_author
=head2 count_dists_per_year
=head2 count_kwalitee_dists
=head2 dbname
=head2 get_author_history
=head2 get_author_kwalitee
=head2 get_author_kwalitee_list
=head2 get_authors_by_rank
=head2 get_dependent_dists_by_id
=head2 get_dist
=head2 get_dist_errors_by_id
=head2 get_dist_history
=head2 get_dist_kwalitee_by_id
=head2 get_dist_kwalitee_list
=head2 get_dist_modules_by_id
=head2 get_dist_prereqs_by_id
=head2 get_dist_uses_by_id
=head2 get_failing_dists
=head2 get_kwalitee_overview
=head2 get_most_kwalitative_authors
=head2 get_most_kwalitative_dists
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
