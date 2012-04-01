use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dist::Overview;

sub load { WWW::Acme::CPANAuthors::Page::Dist::Overview->load_data(@_) }

{
  my $got = load('Acme-CPANAuthors');
  ok $got && %{$got->{dist}}, "got dist";
  ok $got && %{$got->{kwalitee}}, "got kwalitee";
  # note explain $got;
}

done_testing;
