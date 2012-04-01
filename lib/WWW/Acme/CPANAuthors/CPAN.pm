package WWW::Acme::CPANAuthors::CPAN;

use strict;
use warnings;
use Exporter::Lite;
use WWW::Acme::CPANAuthors::PathUtils;

our $MIRROR = 'http://cpan.charsbar.org/mirror/';
our @EXPORT = qw/cpanfile cpandir/;

my $root;
sub root {
  $root ||= do {
    my $dir;
    if ($ENV{ACME_CPANAUTHORS_HOME}) {
      $dir = Path::Extended::Dir->new($ENV{ACME_CPANAUTHORS_HOME});
      return $dir if $dir->subdir('authors/id/')->exists;
    }

    require File::HomeDir;
    my $home = Path::Extended::Dir->new(File::HomeDir->my_home);
    for (qw/cpan cpan_mirror/) {
      my $dir = $home->subdir($_);
      return $dir if $dir->subdir('authors/id/')->exists;
    }

    # XXX: also .minicpanrc or CPAN::(My)Config?

    die "requires a local CPAN mirror\n";
  };
}

sub file { _file(__PACKAGE__->root, @_) }
sub dir  { _dir(__PACKAGE__->root, @_) }

*cpanfile = \&file;
*cpandir  = \&dir;

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::CPAN

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 root
=head2 file, cpanfile
=head2 dir, cpandir

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
