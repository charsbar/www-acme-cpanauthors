use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Kwalitee::Chart::Overview;

sub load { WWW::Acme::CPANAuthors::Page::Kwalitee::Chart::Overview->load_data(@_) }

{
  my $got = load('Acme-CPANAuthors');
  ok $got && @{$got->{xaxis}}, "got xaxis";
  ok $got && @{$got->{series}}, "got series";
  ok $got && $got->{series}[0]{name} eq 'PASS', "got PASS series";
  ok $got && $got->{series}[1]{name} eq 'FAIL', "got FAIL series";
}

done_testing;
