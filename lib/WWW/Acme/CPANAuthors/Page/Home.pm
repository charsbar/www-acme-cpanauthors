package WWW::Acme::CPANAuthors::Page::Home;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;
use WWW::Acme::CPANAuthors::Utils;
use WWW::Acme::CPANAuthors::WorldPopulation;
use String::CamelCase 'camelize';

sub load_data { slurp_json('page/home') }

sub create_data {
  my $class = shift;

  my @listed_ids = db('CPAN')->get_listed_author_ids;
  my $listed_authors = scalar @listed_ids;
  my $listed_active_authors = db('Uploads')->count_active_authors(\@listed_ids);
  my $all_active_authors = db('Uploads')->count_active_authors;

  my @category_ids = db('CPAN')->get_category_ids;
  my %authors_by_category;
  my %ratio_by_category;
  my $all_authors = db('CPAN')->count_total_authors;

  my $num_of_authors = db('CPAN')->count_listed_authors;
  for (@$num_of_authors) {
    my $id = $_->{category_id};
    $authors_by_category{$id} = $_->{count};
    my $country = country($id);
    my $population = population($id);
    if ($country && $population) {
      $ratio_by_category{$id} = $authors_by_category{$id} / $population * 1_000_000;
    }
  }

  my ($largest_group_id, $second_largest_group_id) = (
    sort { $authors_by_category{$b} <=> $authors_by_category{$a} }
    grep { country($_) }
    keys %authors_by_category
  )[0, 1];

  my $highest_ratio_id = (
    sort { $ratio_by_category{$b} <=> $ratio_by_category{$a} }
    keys %ratio_by_category
  )[0];

  my %data = (
    num_of_modules => db('CPAN')->count_acme_cpanauthors_modules,
    num_of_listed_authors => $listed_authors,
    num_of_all_authors => $all_authors,
    num_of_listed_active_authors => $listed_active_authors,
    num_of_all_active_authors => $all_active_authors,
    listed_authors_percentage
      => percent($listed_authors, $all_authors),
    listed_active_authors_percentage
      => percent($listed_active_authors, $all_active_authors),
    largest_group_name
      => camelize($largest_group_id),
    num_of_largest_group_authors
      => $authors_by_category{$largest_group_id},
    second_largest_group_name
      => camelize($second_largest_group_id),
    num_of_second_largest_group_authors
      => $authors_by_category{$second_largest_group_id},
    highest_ratio_group
      => camelize($highest_ratio_id),
    highest_ratio
      => decimal($ratio_by_category{$highest_ratio_id}),
    population_with_the_highest_ratio
      => population($highest_ratio_id),
  );

  save_json('page/home', \%data);
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Home

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
