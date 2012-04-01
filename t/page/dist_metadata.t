use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dist::Metadata;

sub load { WWW::Acme::CPANAuthors::Page::Dist::Metadata->load_data(@_) }

{
  my $got = load('Acme-CPANAuthors');
  ok $got && $got->{dist}, "got dist";
  ok $got && $got->{meta}, "got dist meta";
  # note explain $got;
}

done_testing;
