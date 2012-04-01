use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Authors;

sub search { WWW::Acme::CPANAuthors::Page::Authors->load_data(@_) }

{
  my $got = search('ISHIGAKI');
  ok $got && @{$got->{authors}} == 1 && $got->{authors}[0]{name} eq 'Kenichi Ishigaki', "got only me";
}

{
  my $got = search('IS');
  ok $got->{authors} && @{$got->{authors}} > 15, "got several candidates";
}

{
  my $got = search('___NOT_EXIST___');
  ok $got->{authors} && !@{$got->{authors}}, "got no authors with a not-existing ID";
}

{
  my $got = search('0');
  ok $got->{authors} && !@{$got->{authors}}, "got no authors with a zero";
}

{
  my $got = search('');
  ok $got->{authors} && !@{$got->{authors}}, "got no authors with an empty string";
}

{
  my $got = search(undef);
  ok $got->{authors} && !@{$got->{authors}}, "got no authors with an undef";
}

{
  my $got = search(';delete from cpan_authors');
  ok $got->{authors} && !@{$got->{authors}}, "got no authors with an illegal sql statement";

  # should not be deleted
  $got = search('ISHIGAKI');
  is $got->{authors}[0]{name} => 'Kenichi Ishigaki', "no SQL injection";
}

done_testing;
