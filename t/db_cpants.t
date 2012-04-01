use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::DB::CPANTS;
use WWW::Acme::CPANAuthors::AcmeLibs;
use IO::Capture::Stderr;

my $db = WWW::Acme::CPANAuthors::DB::CPANTS->new(
  profile => 0,
  trace => 0,
  explain => 1,
);

plan skip_all => 'requires valid cpants.db' unless -f $db->dbfile && -s _;

my $authors = WWW::Acme::CPANAuthors::AcmeLibs->authors('Japanese');
my @pauseids = keys %$authors;

sub no_scan_table (&;$$) {
  my ($test, $description, $skip) = @_;
  my @caller = caller;
  my $line = $caller[2];
  $description ||= "line $line";

  my $capture = IO::Capture::Stderr->new;
  $capture->start;
  $test->();
  $capture->stop;
  my @captured = $capture->read;
  my @scan_table = grep { /SCAN TABLE/ && !/COVERING INDEX/ } @captured;
  SKIP: { 
    skip "known slow query: line $line", 1 if $skip;
    ok !@scan_table, "no scan table: $description"; # or note join "", @captured;
  }
  note join "", @captured;
}

{
  ok $db->add_index, "added index";
}

# page/author

no_scan_table {
  my $got = $db->get_author_kwalitee('ISHIGAKI');
  ok $got, "got ISHIGAKI's kwalitee";
};

no_scan_table {
  my $got = $db->get_dist_kwalitee_list([qw/Acme-CPANAuthors Acme-CPANAuthors-Japanese/]);
  ok $got && @$got, "got list";
  my ($aca) = grep {$_->{dist} eq 'Acme-CPANAuthors'} @$got;
  ok $aca && $aca->{dist}, "got Acme-CPANAuthors kwalitee";
};

# page/author/chart

no_scan_table {
  my $got = $db->get_author_history('ISHIGAKI');
  ok $got && @$got, "got ISHIGAKI's history";
};

# page/for, etc

no_scan_table {
  my $got = $db->get_author_kwalitee_list(\@pauseids);
  ok $got && @$got, "got kwalitee list";
  my ($me) = grep {$_->{pauseid} eq 'ISHIGAKI'} @$got;
  ok $me && $me->{name} eq 'Kenichi Ishigaki', "including mine";
};

# page/dist/*

no_scan_table {
  my $got = $db->get_dist('Acme-CPANAuthors');
  ok $got && $got->{dist} eq 'Acme-CPANAuthors', "got dist";
};

no_scan_table {
  my $dist = $db->get_dist('Acme-CPANAuthors');
  my $got = $db->get_dist_kwalitee_by_id($dist->{id});
  ok $got && $got->{kwalitee}, "got dist kwalitee";
};

# page/dist/chart

no_scan_table {
  my $got = $db->get_dist_history('Acme-CPANAuthors');
  ok $got && @$got, "got Acme-CPANAuthors's history";
};

# page/dist/metadata

no_scan_table {
  my $dist = $db->get_dist('Acme-CPANAuthors');
  my $got = $db->get_dist_errors_by_id($dist->{id});
  ok $got && $got->{id}, "got Acme-CPANAuthors's errors";
};

# page/dist/prereq

no_scan_table {
  my $dist_id = $db->get_dist('Acme-CPANAuthors')->{id};
  my $got = $db->get_dist_prereqs_by_id($dist_id);
  ok $got && @$got, "got Acme-CPANAuthors's prereqs";
};

no_scan_table {
  my $dist_id = $db->get_dist('Acme-CPANAuthors')->{id};
  my $got = $db->get_dist_uses_by_id($dist_id);
  ok $got && @$got, "got Acme-CPANAuthors's uses";
};

# page/dist/provides

no_scan_table {
  my $dist_id = $db->get_dist('Acme-CPANAuthors')->{id};
  my $got = $db->get_dist_modules_by_id($dist_id);
  ok $got && @$got, "got Acme-CPANAuthors's modules";
};

# page/dist/usedby

no_scan_table {
  my $dist_id = $db->get_dist('Acme-CPANAuthors')->{id};
  my $got = $db->get_dependent_dists_by_id($dist_id);
  ok $got && @$got, "got Acme-CPANAuthors's dependent dists";
};



# ranking

no_scan_table {
  my $got = $db->get_most_kwalitative_authors;
  ok $got && @$got, "got ".(scalar @$got)." most kwalitative authors";
};

no_scan_table {
  my $got = $db->get_authors_by_rank;
  ok $got && @{$got->{rows}}, "got ".(scalar @{$got->{rows}})." most kwalitative authors";
  $got = $db->get_authors_by_rank({page => 2});
  ok $got && @{$got->{rows}}, "got second ".(scalar @{$got->{rows}})." most kwalitative authors";
};

# kwalitee

no_scan_table {
  my $got = $db->get_failing_dists('extractable');
  ok $got && @$got, "got failing dists";
} "failing tests", "slow query";

no_scan_table {
  my $warning;
  local $SIG{__WARN__} = sub { $warning = $_[0] };
  my $got = $db->get_failing_dists('unkwown_metric;');
  ok !$got, "got no dists";
  like $warning => qr/requires a valid metric/, "got a warning";
};

# search

no_scan_table {
  my $got = $db->search_dists('Japanese');
  ok $got && @$got, "got dists";
};

# graphs

no_scan_table {
  my $got = $db->get_kwalitee_overview;
  ok $got && $got->{total} && $got->{extractable}, "got overview";
} "kwalitee overview", "slow query";

no_scan_table {
  my $got = $db->count_kwalitee_dists;
  ok $got && @$got, "got kwalitee dists";
} "kwalitee dists", "slow query";

no_scan_table {
  my $got = $db->count_dists_per_author;
  ok $got && @$got, "got dists per author";
};

no_scan_table {
  my $got = $db->count_dists_per_year;
  ok $got && @$got, "got dists per year";
  my ($y2000) = grep {$_->{year} eq '2000'} @$got;
  ok $y2000 && $y2000->{count}, "got y2000 count";
} "count_dists_per_year", "slow_query";

done_testing;
