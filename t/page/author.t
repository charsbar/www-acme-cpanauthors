use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Author;

sub load { WWW::Acme::CPANAuthors::Page::Author->load_data(@_) }

{
  my $got = load('ISHIGAKI');
  ok $got && %{$got->{author_info}}, "got author info";
  ok $got && %{$got->{author_kwalitee_info}}, "got author kwalitee info";
  ok $got && @{$got->{dists}}, "got author dists";
}

done_testing;
