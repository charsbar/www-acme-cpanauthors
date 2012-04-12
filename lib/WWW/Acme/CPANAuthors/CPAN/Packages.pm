package WWW::Acme::CPANAuthors::CPAN::Packages;

use strict;
use warnings;
use base 'WWW::Acme::CPANAuthors::CPAN::Index';
use CPAN::DistnameInfo;
use CPAN::Version;

sub id { 'modules/02packages.details.txt' }

sub _parse {
  my ($class, $handle, $callback) = @_;

  my $seen_headers;
  while(my $line = $handle->getline) {
    chomp $line;
    $seen_headers = 1 unless $line;
    next unless $seen_headers;
    next unless $line;

    my ($package, $version, $tarball) = split /\s+/, $line, 3;
    $callback->($package, $version, $tarball, $line) or next;
  }
}

sub register {
  my ($class, $db) = @_;

  # TODO: see what PAUSE actually does.
  my %dists;
  $class->parse(sub {
    my ($package, $version, $tarball, $line) = @_;
    my $dist = CPAN::DistnameInfo->new($tarball);
    my $name = $dist->dist;
    unless ($name) {
      # warn "DISTNAME NOT FOUND: $tarball\n";
      return;
    }
    if (!$dists{$name} or CPAN::Version->vgt($dist->version, $dists{$name}[1])) {
      $dists{$name} = [$name, $dist->version, $dist->cpanid, $tarball];
    }
  });
  $db->register_packages([values %dists]);
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::CPAN::Packages

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 id

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
