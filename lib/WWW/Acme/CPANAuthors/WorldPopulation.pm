package WWW::Acme::CPANAuthors::WorldPopulation;

use strict;
use warnings;
use Web::Scraper;
use URI;
use WWW::Acme::CPANAuthors::JSON;
use Sub::Install qw/reinstall_sub/;

our @EXPORT = qw/country population isa_country isa_region/;

my %POPULATION;
my %TABLE = (
  austrian   => 'Austria',
  brazilian  => 'Brazil',
  british    => 'United Kingdom',
  canadian   => 'Canada',
  chinese    => 'China',
  danish     => 'Denmark',
  dutch      => 'Netherlands',
  french     => 'France',
  german     => 'Germany',
  icelandic  => 'Iceland',
  israeli    => 'Israel',
  india      => 'India',
  indonesian => 'Indonesia',
  italian    => 'Italy',
  japanese   => 'Japan',
  korean     => 'South Korea',
  norwegian  => 'Norway',
  portuguese => 'Portugal',
  russian    => 'Russia',
  spanish    => 'Spain',
  swedish    => 'Sweden',
  taiwanese  => 'Taiwan',
  turkish    => 'Turkey',
  ukrainian  => 'Ukraine',

  arabic      => 0,
  catalonian  => 0,
  eu          => 0,
  european    => 0,

  acme_cpanauthors_authors => undef,
  anyevent    => undef,
  cpants_fiveormore => undef,
  duallife    => undef,
  github      => undef,
  poe         => undef,
  pumpkings   => undef,
  tobelike    => undef,

  coderepos   => undef,
  female      => undef,
  geekhouse   => undef,
  misanthrope => undef,
  booking     => undef,
  british_companies => undef,
  you_re_using => undef,
);

sub import {
  my $class = shift;

  if (json_file('world_population')->exists) {
    $class->load;
  }

  my $caller = caller;
  for (@EXPORT) {
    reinstall_sub({code => $_, into => $caller});
  }
}

sub url { 'http://en.wikipedia.org/wiki/List_of_countries_by_population' }

sub load { %POPULATION = %{ slurp_json('world_population') || {}} }

sub scrape {
  my $class = shift;

  my $file = json_file('world_population');
  if ($file->exists && $file->mtime < time - 12 * 60 * 60) {
    $class->load;
  }
  else {
    my $scraper = scraper {
      process 'table.wikitable>tr',
        'rows[]' => scraper {
          process 'td:nth-child(2) a' => 'country' => 'TEXT';
          process 'td:nth-child(3)' => 'population' => sub {
            my $text = shift->as_text;
            $text =~ s/\D//g;
            $text;
          };
          result qw/country population/;
        };
      result qw/rows/;
    };

    my $rows = $scraper->scrape(URI->new($class->url)) or die $!;
    shift @$rows; # to remove a header
    die "no population data" unless @$rows;

    for my $row (@$rows) {
      next unless $row->{country};

      # entries for Taiwan/China are renamed too frequently
      if ($row->{country} =~ /Taiwan|Republic of China/) {
        $row->{country} = 'Taiwan';
      }
      elsif ($row->{country} =~ /China/) {
        $row->{country} = 'China';
      }

      $POPULATION{$row->{country}} = $row->{population};
    }
    save_json($file, \%POPULATION);
  }	

  \%POPULATION;
}

sub recognizes {
  my ($class, $id) = @_;
  exists $TABLE{$id} ? 1 : 0;
}

sub country_ids {
  sort grep { $TABLE{$_} } keys %TABLE;
}

sub region_ids {
  sort grep { defined $TABLE{$_} } keys %TABLE;
}

sub isa_country { $TABLE{$_[0]} ? 1 : 0 }
sub isa_region  { defined $TABLE{$_[0]} ? 1 : 0 }

sub population {
  my $id = shift;
  return unless isa_country($id);
  unless (%POPULATION) {
    warn "scraping population\n";
    __PACKAGE__->scrape;
  }
  $POPULATION{$TABLE{$id}};
}

sub country { $TABLE{$_[0]} }

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::WorldPopulation

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 country
=head2 country_ids
=head2 isa_country
=head2 isa_region
=head2 load
=head2 population
=head2 recognizes
=head2 region_ids
=head2 scrape
=head2 url

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
