package WWW::Acme::CPANAuthors::Page::Authors;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;

sub load_data {
  my ($class, $name) = @_;

  my $authors = length $name
                  ? db('CPAN')->search_authors($name)
                  : [];

  return { authors => $authors };
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Authors

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
