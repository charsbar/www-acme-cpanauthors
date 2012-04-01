package WWW::Acme::CPANAuthors::Page::Ranking::FiveOrMore;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;

sub load_data {
  my ($class, $page) = @_;
  if (($page || 1) == 1) {
    slurp_json('ranking_five_or_more');
  }
  else {
    db('CPANTS')->get_authors_by_rank({page => $page, liga => 'more'});
  }
}

sub create_data {
  my $class = shift;

  my $authors = db('CPANTS')->get_authors_by_rank({page => 1, liga => 'more'});
  save_json('ranking_five_or_more', $authors);
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Ranking::FiveOrMore

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
