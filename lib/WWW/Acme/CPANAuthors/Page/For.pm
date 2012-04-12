package WWW::Acme::CPANAuthors::Page::For;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;
use WWW::Acme::CPANAuthors::WorldPopulation;

sub load_data { slurp_json("page/for/$_[1]") }

sub create_data {
  my $class = shift;

  my %recent_dists;
  for my $category (@{ db('CPAN')->get_categories }) {
    my $id = $category->{category_id};
    my $country = country($id);
    my $authors = db('CPAN')->get_listed_authors([$id]);
    my @pauseids = map {$_->{pause_id}} @$authors;
    my %mapping;
    for (@$authors) {
      my $pauseid = $_->{pauseid} = delete $_->{pause_id};
      $mapping{$pauseid} = $_;
    }
    my $kwalitee_list = db('CPANTS')->get_author_kwalitee_list(\@pauseids);

    $mapping{$_->{pauseid}} = $_ for @$kwalitee_list;

    my $dists  = db('CPAN')->count_dists_by(\@pauseids);
    for (@$dists) {
      $mapping{$_->{pause_id}}{num_dists} = $_->{count};
    }
    my $recent = db('Uploads')->count_recent_dists_by(\@pauseids);
    for (@$recent) {
      $mapping{$_->{author}}{num_recent_dists} = $_->{count};
    }

    save_json("page/for/$id", {
      category_id => $id,
      country => $country,
      basename => $country ? ucfirst $id : $category->{category},
      package => $category->{category},
      authors => [map {$mapping{$_}} sort keys %mapping],
      num_of_authors => scalar keys %mapping,
    });
  }

  return 1;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::For

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
