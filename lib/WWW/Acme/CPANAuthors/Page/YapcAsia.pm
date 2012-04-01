package WWW::Acme::CPANAuthors::Page::YapcAsia;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::JSON;

# lightning-talk/reject-conf-only speakers are not counted yet.
our %SPEAKERS_FROM_ABROAD = (
  2006 => [qw/AUDREYT CLKAO DCONWAY DROLSKY INGY JESSE GUGOD SARTAK LWALL LBROCARD KASEI/],
  2007 => [qw/INGY SONNY MJD BTROTT KASEI AUDREYT JESSE JROCKWAY GUGOD BRADFITZ AUDREYT CLKAO JKIM MIYAGAWA/],
  2008 => [qw/COG LWALL GUGOD INGY JSHIRLEY LBROCARD JESSE CLKAO MSCHWERN NUFFIN CWEST FAIZ JKIM SONNY MIYAGAWA/],
  2009 => [qw/RDICE SARTAK GUGOD BEPPU JONATHAN FLORA COG CORNELIUS CLKAO JESSE NUFFIN JROCKWAY MIYAGAWA JJNAPIORK/],  # songhee-han has no Pause ID?
  2010 => [qw/LWALL JESSE ABIGAIL JROCKWAY SEMUELF CLKAO SARTAK GUGOD CORNELIUS MIYAGAWA/], # Tarjei Vassbotn and Hakon Skaarud Karlsen have no pause id (Karen Pauley also has none, but she is a LT speaker)
  2011 => [qw/JESSE RJBS MLEHMANN GUGOD SARTAK MIYAGAWA/],
);

sub load_data { slurp_json("page/yapcasia/$_[1]") }

sub create_data {
  my $class = shift;

  my %speakers;
  for my $year (keys %SPEAKERS_FROM_ABROAD) {
    $speakers{$_} = 1 for @{$SPEAKERS_FROM_ABROAD{$year}};
  }
  my @pauseids = keys %speakers;
  my $kwalitee_list = db('CPANTS')->get_author_kwalitee_list(\@pauseids);
  $speakers{$_->{pauseid}} = $_ for @$kwalitee_list;

  my $dists  = db('Uploads')->count_dists_by(\@pauseids);
  for (@$dists) {
    $speakers{$_->{author}}{num_dists} = $_->{count};
  }
  my $recent = db('Uploads')->count_recent_dists_by(\@pauseids);
  for (@$recent) {
    $speakers{$_->{author}}{num_recent_dists} = $_->{count};
  }

  save_json("page/yapcasia/all", {
    year => '',
    authors => [map {$speakers{$_}} sort keys %speakers],
    num_of_authors => scalar keys %speakers,
  });

  for my $year (keys %SPEAKERS_FROM_ABROAD) {
    my @authors = @{$SPEAKERS_FROM_ABROAD{$year}};
    save_json("page/yapcasia/$year", {
      year => $year,
      authors => [map {$speakers{$_}} sort @authors],
      num_of_authors => scalar @authors,
    });
  }

  return 1;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::YapcAsia

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
