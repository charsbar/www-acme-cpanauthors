use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dist::Chart;

sub load { WWW::Acme::CPANAuthors::Page::Dist::Chart->load_data(@_) }

{
  my $got = load('Acme-CPANAuthors');
  ok $got && @{$got->{xaxis}}, "got xaxis";
  ok $got && @{$got->{series}}, "got series";
  ok $got && $got->{series}[0]{name} eq "Kwalitee", "first series is for Kwalitee";
  ok $got && @{$got->{series}[0]{data}}, "got first series data";
}

done_testing;
