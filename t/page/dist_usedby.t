use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dist::UsedBy;

sub load { WWW::Acme::CPANAuthors::Page::Dist::UsedBy->load_data(@_) }

{
  my $got = load('Acme-CPANAuthors');
  ok $got && $got->{dist}, "got dist";
  ok $got && @{$got->{deps}}, "got deps";
  # note explain $got;
}

done_testing;
