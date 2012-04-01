use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::WorldPopulation;
use WWW::Acme::CPANAuthors::AcmeLibs;

WWW::Acme::CPANAuthors::WorldPopulation->scrape;

for (WWW::Acme::CPANAuthors::AcmeLibs->ids) {
  ok(WWW::Acme::CPANAuthors::WorldPopulation->recognizes($_), "recognizes $_");
  next unless isa_country($_);
  my $p = population($_);
  ok $p, "$_ people: $p";
}

done_testing;
