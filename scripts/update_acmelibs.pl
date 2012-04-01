#!/usr/bin/evn perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::Acme::CPANAuthors::Script::update_acmelibs->run_directly;

package WWW::Acme::CPANAuthors::Script::update_acmelibs;
use base 'CLI::Dispatch::Command';
use WWW::Acme::CPANAuthors::AcmeLibs;

sub run {
  my $self = shift;
  my @files = WWW::Acme::CPANAuthors::AcmeLibs->update;
  if ($self->{verbose}) {
    $self->log(info => "updated $_") for @files;
  }
}
