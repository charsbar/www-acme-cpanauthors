package WWW::Acme::CPANAuthors::AppRoot;

use strict;
use warnings;
use Exporter::Lite;
use Path::Extended::File;
use WWW::Acme::CPANAuthors::PathUtils;

our @EXPORT = qw/file dir/;

our $ROOT;
sub root {
  $ROOT ||= do {
    my $dir = Path::Extended::File->new(__FILE__)->parent;
    until ($dir->file('Makefile.PL')->exists) {
      die "Can't find AppRoot\n" if $dir eq $dir->parent;
      $dir = $dir->parent;
    }
    $dir;
  };
}

sub file { _file(__PACKAGE__->root, @_) }
sub dir  { _dir(__PACKAGE__->root, @_) }

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::AppRoot

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 root
=head2 file, dir

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
