package WWW::Acme::CPANAuthors::CPAN::Index;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::CPAN;

sub file {
  my $class = shift;

  my $id = $class->id;
  for my $ext ('.gz', '') {
    my $file = cpanfile("$id$ext");
    return $file if $file->exists;
  }
  die "Can't find index: $id\n";
}

sub parse {
  my ($class, $callback) = @_;

  my $file = $class->file;
  my $handle;

  if ($file =~ /\.gz$/) {
    require IO::Uncompress::Gunzip;
    $handle = IO::Uncompress::Gunzip->new($file->path);
  }
  else {
    $handle = $file->openr;
  }

  $class->_parse($handle, $callback);
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::CPAN::Index

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 file
=head2 parse

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
