use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

WWW::Acme::CPANAuthors::Script::update_cpandb->run_directly;

package WWW::Acme::CPANAuthors::Script::update_cpandb;
use base 'CLI::Dispatch::Command';
use WWW::Acme::CPANAuthors::DB::CPAN;

sub run {
  my $self = shift;

  WWW::Acme::CPANAuthors::DB::CPAN->new->setup_and_register;
}
