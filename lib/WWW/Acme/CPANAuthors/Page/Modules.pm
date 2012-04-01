package WWW::Acme::CPANAuthors::Page::Modules;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;
use WWW::Acme::CPANAuthors::Utils;
use WWW::Acme::CPANAuthors::WorldPopulation;

sub load_data { slurp_json('page/modules') }

sub create_data {
  my $class = shift;

  my @categories = @{ db('CPAN')->get_categories };

  my $total_dists = db('Uploads')->count_total_dists_by;

  my (@regional_modules, @non_regional_modules);
  for my $category (@categories) {
    my $id = $category->{category_id};
    my @listed_ids = db('CPAN')->get_listed_author_ids([$id]);

    my $kwalitee_list = db('CPANTS')->get_author_kwalitee_list(\@listed_ids);
    my $ave_kwalitee = 0;
    for (@$kwalitee_list) {
      $ave_kwalitee += $_->{average_kwalitee};
    }
    $ave_kwalitee /= @listed_ids if @listed_ids;

    my $num_of_dists = @listed_ids ? db('Uploads')->count_total_dists_by(\@listed_ids) : 0;

    my $country = country($id);

    if ($country or $id =~ /^eu(?:ropean)?/) {
      my $population = population($id);

      push @regional_modules, {
        id => $id,
        name
          => $category->{category},
        version
          => $category->{version},
        authors
          => scalar @listed_ids,
        actives
          => @listed_ids ? db('Uploads')->count_active_authors(@listed_ids) : 0,
        population => $population,
        ratio
          => $population ? decimal((scalar @listed_ids) / $population * 1_000_000) : '',
        dists
          => $num_of_dists,
        dists_ratio
          => $total_dists ? percent($num_of_dists, $total_dists) : '-',
        average_kwalitee => decimal($ave_kwalitee),
      };
    }
    else {
      push @non_regional_modules, {
        id => $id,
        name => $category->{category},
        version => $category->{version},
        authors => scalar @listed_ids,
        dists => $num_of_dists,
        average_kwalitee => decimal($ave_kwalitee),
      };
    }
  }

  my %data = (
    num_of_modules => db('CPAN')->count_acme_cpanauthors_modules,
    regional_modules => \@regional_modules,
    non_regional_modules => \@non_regional_modules,
  );

  save_json('page/modules', \%data);
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Modules

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
