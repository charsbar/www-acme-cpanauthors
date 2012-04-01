#!perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Path::Extended;
use File::HomeDir;
use List::Util qw/first/;

my @libs;
BEGIN {
  my $my_home = dir(File::HomeDir->my_home);
  my $cpants_dir = first { $_->exists } 
                   map { $my_home->subdir($_) }
                   qw(cpants gitolite/cpants github/CPANTS);
  if ($cpants_dir) {
    push @libs,
      map  { $_->stringify }
      grep { $_->exists }
      $cpants_dir->subdir('lib'),
      $cpants_dir->subdir('Module-CPANTS-Analyse/lib');
  }
}

use lib @libs;

WWW::Acme::CPANAuthors::Script::GetKwaliteeMetrics->run_directly;

package WWW::Acme::CPANAuthors::Script::GetKwaliteeMetrics;
use base 'CLI::Dispatch::Command';
use Module::CPANTS::Kwalitee;
use WWW::Acme::CPANAuthors::Kwalitee;

sub run {
  my ($self, @args) = @_;
  my $kwalitee = Module::CPANTS::Kwalitee->new;
  $self->log(info => "uses Module::CPANTS::Kwalitee located in $INC{'Module/CPANTS/Kwalitee.pm'}");
  my @indicators = map {
    my $i = $_;
    +{
      map { $_ => $i->{$_} }
      qw/name error remedy is_extra is_experimental/
    }
  } $kwalitee->get_indicators;
  save_metrics(\@indicators);
  $self->log(info => "saved metrics in ".metrics_file());
}
