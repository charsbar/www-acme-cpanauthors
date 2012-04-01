use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::YapcAsia;

sub load { WWW::Acme::CPANAuthors::Page::YapcAsia->load_data(@_) }

{
  diag "wait a minute for creating data";
  ok eval { WWW::Acme::CPANAuthors::Page::YapcAsia->create_data }, "created data";
  warn $@ if $@;
}

{
  my $got = load('2006');
  ok $got && @{$got->{authors}}, "got authors";
  # note explain $got;
}

done_testing;
