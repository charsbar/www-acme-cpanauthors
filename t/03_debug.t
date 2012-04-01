use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Debug;

unless (eval { require IO::Capture::Stderr; 1 }) {
  warn $@ if $@;
  plan skip_all => 'requires IO::Capture::Stderr';
}

{
  sleep 1;

  # scalar context
  my $delta = WWW::Acme::CPANAuthors::Debug->elapsed;
  ok $delta, "got delta: $delta";
}

{
  sleep 1;

  # list context
  my ($delta, $total) = WWW::Acme::CPANAuthors::Debug->elapsed;
  ok $delta, "got delta";
  ok $total, "got total";
}

{
  sleep 1;

  # void context
  my $capture = IO::Capture::Stderr->new;
  $capture->start;
  WWW::Acme::CPANAuthors::Debug->elapsed;
  $capture->stop;
  my $captured = $capture->read;
  chomp $captured;
  ok $captured, "captured: $captured";
}

{
  sleep 1;

  # shortcut
  my $capture = IO::Capture::Stderr->new;
  $capture->start;
  DEBUG->elapsed;
  $capture->stop;
  my $captured = $capture->read;
  chomp $captured;
  ok $captured, "captured: $captured";
}

done_testing;
