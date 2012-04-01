#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::Acme::CPANAuthors::Script::update_pages->run_directly;

package WWW::Acme::CPANAuthors::Script::update_pages;
use base 'CLI::Dispatch::Command';
use WWW::Acme::CPANAuthors::Pages;

sub run {
  my ($self, @target) = @_;

  for my $module (WWW::Acme::CPANAuthors::Pages->loaded) {
    if (@target) {
      next unless grep { $module =~ /::$_/ } @target;
    }
    my $code = $module->can('create_data') or next;
    $self->log(info => "processing $module");
    $code->();
  }
}
