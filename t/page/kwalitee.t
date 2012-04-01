use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Page::Kwalitee;

diag "wait a minute for creating data";
ok eval { WWW::Acme::CPANAuthors::Page::Kwalitee->create_data }, "created data";

my $got = WWW::Acme::CPANAuthors::Page::Kwalitee->load_data;

ok $got && @{$got->{core}};
ok $got && @{$got->{extra}};

done_testing;
