use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Ranking::FiveOrMore;

sub load { WWW::Acme::CPANAuthors::Page::Ranking::FiveOrMore->load_data(@_) }

{
  diag "wait a minute for creating data";
  ok eval { WWW::Acme::CPANAuthors::Page::Ranking::FiveOrMore->create_data }, "created data";
  warn $@ if $@;
}

{
  my $got = load();
  ok $got && @{$got->{rows}}, "got first ranking data";
  ok $got && $got->{next}, "next page should exist";
  ok $got && !$got->{prev}, "prev page should not exist";
}

{
  my $got = load(1);
  ok $got && @{$got->{rows}}, "got first ranking data";
  ok $got && $got->{next}, "next page should exist";
  ok $got && !$got->{prev}, "prev page should not exist";
}

{
  my $got = load(2);
  ok $got && @{$got->{rows}}, "got second ranking data";
  ok $got && $got->{next}, "next page should exist";
  ok $got && $got->{prev}, "prev page should exist now";
}

done_testing;
