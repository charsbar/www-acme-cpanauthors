use strict;
use warnings;
use Test::More;
use List::Util qw/sum/;
use WWW::Acme::CPANAuthors::DB::CPAN;

my $db = WWW::Acme::CPANAuthors::DB::CPAN->new(
  profile => 0,
  trace => 0,
  explain => 1,
);

{
  unless (-f $db->dbfile && -s _) {
    unlink $db->dbfile;
    $db->setup_and_register;
  }
}

{
  my $got = $db->get_listed_authors([qw/Japanese/]);
  ok $got && @$got > 200, "more than 200 Japanese authors are listed";
  note scalar @$got;
  my ($me) = grep {$_->{pause_id} eq 'ISHIGAKI'} @$got;
  ok $me && $me->{name} eq 'Kenichi Ishigaki', "including me" or note explain $me;
}

{
  my $got = $db->get_listed_author_ids([qw/Japanese/]);
  ok $got && @$got > 200, "more than 200 Japanese author ids are listed";
  note scalar @$got;
  my ($me) = grep {$_ eq 'ISHIGAKI'} @$got;
  ok $me, "including me" or note explain $me;
}

{
  my $got = $db->get_author_info('ISHIGAKI');
  ok $got->{name} eq 'Kenichi Ishigaki', "name is correct";
  ok @{$got->{listed}}, "listed in several modules";
}

{
  my $got = $db->search_authors('IS');
  ok $got && @$got, "found several candidates";
  my ($me) = grep {$_->{pause_id} eq 'ISHIGAKI'} @$got;
  ok $me, "including me" or note explain $me;
}

{
  my $got = $db->get_category_ids;
  ok $got && @$got, "got ".(scalar @$got)." category ids";
}

{
  my $count = $db->count_acme_cpanauthors_modules;
  ok $count, "$count Acme::CPANAuthors modules";
}

{
  my $got = $db->count_listed_authors;
  ok $got && @$got, "counted listed authors";
  my ($jp) = grep {$_->{category_id} eq 'japanese'} @$got;
  ok $jp->{count} > 260, "more than 260 Japanese authors";

  # notable exception :)
  my ($dutch) = grep {$_->{category_id} eq 'dutch'} @$got;
  ok $dutch->{count} == 0, "0 Dutch authors";
}

{
  my $got = $db->count_listed_authors([qw/japanese/]);
  ok $got && @$got, "counted authors";
  my ($jp) = grep {$_->{category_id} eq 'japanese'} @$got;
  ok $jp->{count} > 260, "more than 260 Japanese authors";
}

{
  my $count = $db->count_total_authors;
  ok $count, "$count CPAN authors";

  my $got = $db->count_listed_authors;
  ok $count > sum(map {$_->{count}} @$got), "total authors should be larger than the sum of listed authors";
}

{
  my $got = $db->get_categories;
  ok $got && @$got, "got ".(scalar @$got)." categories";
  my ($jp) = grep {$_->{category_id} eq 'japanese'} @$got;
  ok $jp && $jp->{category} eq 'Acme::CPANAuthors::Japanese', 'including Japanese';
}

done_testing;
