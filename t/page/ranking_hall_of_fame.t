use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Ranking::HallOfFame;

{
  diag "wait a minute for creating data";
  ok eval { WWW::Acme::CPANAuthors::Page::Ranking::HallOfFame->create_data }, "created data";
  warn $@ if $@;
}

{
  my $got = WWW::Acme::CPANAuthors::Page::Ranking::HallOfFame->load_data;
  ok $got & @{$got->{dists}}, "got dists";
}

done_testing;
