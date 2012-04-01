package WWW::Acme::CPANAuthors::Page::Dist::Overview;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::Kwalitee;
use WWW::Acme::CPANAuthors::Utils;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db('CPANTS')->get_dist($name);
  my $kwalitee = db('CPANTS')->get_dist_kwalitee_by_id($dist->{id});

  my %kwalitees;
  @kwalitees{qw/core extra/} = sorted_metrics($kwalitee, requires_remedy => 1);
  my %data = (
    dist => $dist,
    kwalitee => \%kwalitees,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Dist::Overview

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 load_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut