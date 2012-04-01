use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dist::Prereq;

sub load { WWW::Acme::CPANAuthors::Page::Dist::Prereq->load_data(@_) }

{
  my $got = load('Moose');
  ok $got && %{$got->{dist}}, "got dist";
  ok $got && @{$got->{prereqs}}, "got prereqs";
  ok $got && @{$got->{build_prereqs}}, "got build_prereqs";
  ok $got && @{$got->{optional_prereqs}}, "got optional_prereqs";
  ok $got && @{$got->{used_in_code}}, "got used_in_code";
  ok $got && @{$got->{used_in_tests}}, "got used_in_tests";
  # note explain $got;
}

done_testing;
