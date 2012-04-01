use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Dist::Provides;

sub load { WWW::Acme::CPANAuthors::Page::Dist::Provides->load_data(@_) }

{
  my $got = load('Acme-CPANAuthors');
  ok $got && $got->{dist}, "got dist";
  ok $got && @{$got->{modules}}, "got modules";
  # note explain $got;
}

done_testing;
