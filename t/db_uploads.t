use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::AcmeLibs;
use WWW::Acme::CPANAuthors::DB::Uploads;
use WWW::Acme::CPANAuthors::Utils;

my $db = WWW::Acme::CPANAuthors::DB::Uploads->new(
  profile => 0,
  trace => 0,
  explain => 1,
);
plan skip_all => 'requires valid uploads.db' unless -f $db->dbfile && -s _;

my $authors = WWW::Acme::CPANAuthors::AcmeLibs->authors('Japanese');
my @pause_ids = keys %$authors;

{
  ok $db->add_index, "add index";
}

{
  my $got = $db->count_dists_by(\@pause_ids);
  ok $got && @$got;
  my ($me) = grep {$_->{author} eq 'ISHIGAKI'} @$got;
  ok $me && $me->{count}, "ISHIGAKI has $me->{count} dists";
}

{
  my $got = $db->count_recent_dists_by(\@pause_ids);
  ok $got && @$got;
  my ($me) = grep {$_->{author} eq 'ISHIGAKI'} @$got;
  ok $me && $me->{count}, "ISHIGAKI updated $me->{count} dists recently";
}

{
  my $count = $db->count_total_dists_by(\@pause_ids);
  ok $count, "Japanese authors have $count dists";
}

{
  my $count = $db->count_total_recent_dists_by(\@pause_ids);
  ok $count, "Japanese authors updated $count dists recently";
}

{
  my $count = $db->count_contributed_authors(\@pause_ids);
  ok $count, "$count Japanese authors have contributed";
}

{
  my $count = $db->count_active_authors(\@pause_ids);
  ok $count, "$count Japanese authors are active";
}

{
  my $dists = $db->acme_cpanauthors_dists;
  ok $dists && @$dists;
  my ($jp) = grep { $_->{dist} =~ /Japanese/ } @$dists;
  ok $jp && $jp->{version} && $jp->{released}, "$jp->{dist} $jp->{version} is released on ".date($jp->{released});
}

{
  my $dists = $db->dists_by('ISHIGAKI');
  ok $dists && @$dists;
  my ($jp) = grep { $_->{dist} =~ /Japanese/ } @$dists;
  ok $jp && $jp->{version} && $jp->{released}, "$jp->{dist} $jp->{version} is released on ".date($jp->{released});
}

{
  my $dist = $db->get_latest_dist('Acme-CPANAuthors');
  ok $dist && $dist->{dist} eq 'Acme-CPANAuthors', "got dist";
}

# for graph

{
  my $got = $db->count_dists_per_author;
  ok $got && @$got, "got dists per author";
}

done_testing;
