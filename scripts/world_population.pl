#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib/";

WWW::Acme::CPANAuthors::Script::world_population->run_directly;

package WWW::Acme::CPANAuthors::Script::world_population;
use base 'CLI::Dispatch::Command';
use WWW::Acme::CPANAuthors::WorldPopulation;

sub run {
  my $self = shift;
  WWW::Acme::CPANAuthors::WorldPopulation->scrape;
}
