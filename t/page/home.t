use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Home;

ok eval { WWW::Acme::CPANAuthors::Page::Home->create_data }, "created data";
warn $@ if $@;

my $got = WWW::Acme::CPANAuthors::Page::Home->load_data;

my @should_be_integer = qw/
  num_of_modules
  num_of_listed_authors
  num_of_all_authors
  num_of_all_active_authors
  num_of_largest_group_authors
  num_of_second_largest_group_authors
  population_with_the_highest_ratio
/;

for (@should_be_integer) {
  ok $got && $got->{$_} && $got->{$_} =~ /^[0-9]+$/, "$_ should be non-0 integer";
}

my @should_be_float = qw/
  listed_authors_percentage
  listed_active_authors_percentage
  highest_ratio
/;

for (@should_be_float) {
  ok $got && $got->{$_} && $got->{$_} =~ /^[0-9]+\.[0-9]+$/, "$_ should be non-0 float";
}

my @should_be_string = qw/
  largest_group_name
  second_largest_group_name
  highest_ratio_group
/;

for (@should_be_string) {
  ok $got && $got->{$_} && $got->{$_} =~ /^[^0-9]+$/, "$_ should be string";
}

done_testing;
