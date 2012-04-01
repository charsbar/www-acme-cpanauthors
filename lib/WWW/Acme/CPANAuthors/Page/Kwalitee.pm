package WWW::Acme::CPANAuthors::Page::Kwalitee;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;
use WWW::Acme::CPANAuthors::Kwalitee;

sub load_data { slurp_json('page/kwalitee_overview') }

sub create_data {
  my $class = shift;

  my ($core, $extra) = sorted_metrics({}, requires_remedy => 1);

  my $got = db('CPANTS')->get_kwalitee_overview;
  for (@$core, @$extra) {
    $_->{num_fails} = $got->{total} - $got->{$_->{key}};
  }

  save_json('page/kwalitee_overview', {
    count => $got->{total},
    core  => $core,
    extra => $extra,
  });
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Kwalitee

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
