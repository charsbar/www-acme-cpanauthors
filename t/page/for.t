use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::For;

sub load { WWW::Acme::CPANAuthors::Page::For->load_data(@_) }

{
  diag "wait a minute for creating data";
  ok eval { WWW::Acme::CPANAuthors::Page::For->create_data }, "created data";
  warn $@ if $@;
}

{
  my $got = load('Japanese');
  ok $got && @{$got->{authors}}, "got authors";
  ok $got && $got->{country} eq 'Japan', "got correct country";
  # note explain $got;
}

done_testing;
