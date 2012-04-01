package WWW::Acme::CPANAuthors::Page::Ranking::HallOfFame;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;

sub load_data { slurp_json('ranking_hall_of_fame') }

sub create_data {
  my $class = shift;

  my $dists = db('CPANTS')->get_most_kwalitative_dists;
  save_json('ranking_hall_of_fame', {dists => $dists});
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Ranking::HallOfFame

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 load_data

=head2 create_data

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
