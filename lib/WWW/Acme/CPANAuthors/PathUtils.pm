package WWW::Acme::CPANAuthors::PathUtils;

use strict;
use warnings;
use Exporter::Lite;
use Path::Extended;

our @EXPORT = qw/_file _dir/;

sub _file {
  my $root = shift;
  my $file = $root->file(@_);
  $root->subsumes($file) ? $file : die "external file: $file\n";
}

sub _dir {
  my $root = shift;
  my $dir = $root->subdir(@_);
  $root->subsumes($dir) ? $dir : die "external dir: $dir\n";
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::PathUtils

=head1 DESCRIPTION

Used internally to protect against directory traversal.

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
