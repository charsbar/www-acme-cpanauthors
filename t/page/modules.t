use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Modules;

diag "wait a minute for creating data";
ok eval { WWW::Acme::CPANAuthors::Page::Modules->create_data }, "created data";
warn $@ if $@;

my $got = WWW::Acme::CPANAuthors::Page::Modules->load_data;
ok $got && $got->{num_of_modules}, "got num of modules";
ok $got && @{$got->{regional_modules}}, "got regional modules";
ok $got && @{$got->{non_regional_modules}}, "got non-regional modules";

done_testing;
