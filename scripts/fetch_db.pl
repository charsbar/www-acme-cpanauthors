#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::Acme::CPANAuthors::Script::fetch_db->run_directly;

package WWW::Acme::CPANAuthors::Script::fetch_db;
use base 'CLI::Dispatch::Command';
use WWW::Acme::CPANAuthors::DB;

sub run {
  my $self = shift;
  WWW::Acme::CPANAuthors::DB->fetch($self, @_);
}
