package WWW::Acme::CPANAuthors::Page::Kwalitee::Chart::Overview;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::JSON;
use WWW::Acme::CPANAuthors::Kwalitee;

sub load_data {
  my $class = shift;

  my $got = slurp_json('page/kwalitee_overview');
  my (@metrics, @pass, @fail);
  for (@{$got->{core}}, @{$got->{extra}}) {
    push @metrics, $_->{name};
    push @pass, $got->{count} - $_->{num_fails};
    push @fail, $_->{num_fails};
  }

  return {
    xaxis => \@metrics,
    series => [
      {name => 'PASS', data => \@pass},
      {name => 'FAIL', data => \@fail},
    ],
  }
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Kwalitee::Chart::Overview

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
