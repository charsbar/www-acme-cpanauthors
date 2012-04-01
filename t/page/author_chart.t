use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Author::Chart;

sub load { WWW::Acme::CPANAuthors::Page::Author::Chart->load_data(@_) }

{
  my $got = load('ISHIGAKI');
  ok $got && @{$got->{xaxis}}, "got xaxis";
  ok $got && @{$got->{series}}, "got series";
  ok $got && $got->{series}[0]{name} eq "Kwalitee", "first series is for Kwalitee";
  ok $got && @{$got->{series}[0]{data}}, "got first series data";
  ok $got && $got->{series}[1]{name} eq "Dists", "first series is for Dists";
  ok $got && @{$got->{series}[1]{data}}, "got second series data";
}

done_testing;
