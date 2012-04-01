package WWW::Acme::CPANAuthors::Debug;

use strict;
use warnings;

my $start_time = my $prev = time;

sub elapsed {
  my $class = shift;
  my $time  = time;
  my $delta = $time - $prev;
  my $total = $time - $start_time;
  $prev = $time;
  unless (defined wantarray) {
    print STDERR "elapsed $delta seconds (total: $total)\n";
  }
  wantarray ? ($delta, $total) : $delta;
}

package #
  DEBUG;

sub elapsed { goto &WWW::Acme::CPANAuthors::Debug::elapsed }

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Debug

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 elapsed

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
