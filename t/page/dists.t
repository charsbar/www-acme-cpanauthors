use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dists;

sub search { WWW::Acme::CPANAuthors::Page::Dists->load_data(@_) }

{
  my $got = search('Acme-CPANAuthors');
  ok $got && @{$got->{dists}}, "got dists";
  # note explain $got;
}

done_testing;
