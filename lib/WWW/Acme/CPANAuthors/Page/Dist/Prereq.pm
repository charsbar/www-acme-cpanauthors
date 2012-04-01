package WWW::Acme::CPANAuthors::Page::Dist::Prereq;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::DB;
use WWW::Acme::CPANAuthors::Kwalitee;
use WWW::Acme::CPANAuthors::Utils;

sub load_data {
  my ($class, $name) = @_;

  my $dist = db('CPANTS')->get_dist($name);
  return unless $dist && $dist->{id};

  my $all_prereqs = db('CPANTS')->get_dist_prereqs_by_id($dist->{id});
  my $all_uses = db('CPANTS')->get_dist_uses_by_id($dist->{id});
  for (@$all_uses) {
    if (!defined $_->{module} or !length $_->{module}) {
      $_->{module} = '(eval?)';
    }
    if (!defined $_->{dist_name} or !length $_->{dist_name}) {
      $_->{dist_name} = '?';
    }
  }

  my (@prereqs, @build_prereqs, @optional_prereqs);
  for (@$all_prereqs) {
    push @prereqs, $_          if $_->{is_prereq};
    push @build_prereqs, $_    if $_->{is_build_prereq};
    push @optional_prereqs, $_ if $_->{is_optional_prereq};
  }

  my (@used_in_code, @used_in_tests);
  for (@$all_uses) {
    push @used_in_code, $_  if $_->{in_code};
    push @used_in_tests, $_ if $_->{in_tests};
  }

  my %data = (
    dist => $dist,
    prereqs => \@prereqs,
    build_prereqs => \@build_prereqs,
    optional_prereqs => \@optional_prereqs,
    used_in_code => \@used_in_code,
    used_in_tests => \@used_in_tests,
  );
  return \%data;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Page::Dist::Prereq

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
