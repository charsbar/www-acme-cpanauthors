package WWW::Acme::CPANAuthors::Page::Author;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::Kwalitee;
use WWW::Acme::CPANAuthors::Utils;

sub load_data {
  my ($class, $id) = @_;

  my $author_info = db('CPAN')->get_author_info($id) or return;
  my $author_kwalitee_info = db('CPANTS')->get_author_kwalitee($id);
  my $dists = db('CPAN')->get_dists($id);
  my $kwalitee_list = db('CPANTS')->get_dist_kwalitee_list([map {$_->{dist}} @$dists]);

  my %kwalitee_map;
  for my $kwalitee (@$kwalitee_list) {
    my $dist = delete $kwalitee->{dist};
    $kwalitee_map{$dist} = $kwalitee;
  }

  for (@$dists) {
    $_->{released} = date($_->{released});
    $_->{kwalitee} = $kwalitee_map{$_->{dist}};
    $_->{metrics}  = sorted_metrics($kwalitee_map{$_->{dist}});
  }

  my %data = (
    author_info => $author_info,
    author_kwalitee_info => $author_kwalitee_info,
    dists => $dists,
  );

  \%data;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Author

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
