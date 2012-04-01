package WWW::Acme::CPANAuthors::Test;

use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::AppRoot;
use WWW::Acme::CPANAuthors::PathUtils;
use Exporter::Lite;

our @EXPORT = @Test::More::EXPORT;
our @EXPORT_OK = qw/
  test_home app_root app_file app_dir requires_cpan
/;

our $APP_ROOT = WWW::Acme::CPANAuthors::AppRoot->root;
our $HOME     = dir("tmp/$$")->mkdir;
$WWW::Acme::CPANAuthors::AppRoot::ROOT = $HOME;

sub test_home { $HOME }
sub app_root  { $APP_ROOT }
sub app_file  { _file(__PACKAGE__->app_root, @_) }
sub app_dir   { _dir(__PACKAGE__->app_root, @_) }

sub requires_cpan {
  require WWW::Acme::CPANAuthors::CPAN;
  my $cpan_root = eval { WWW::Acme::CPANAuthors::CPAN->root };
  unless ($cpan_root) {
    return plan skip_all => "requires CPAN mirror for this test";
  }
}

END {
  $WWW::Acme::CPANAuthors::AppRoot::ROOT = $APP_ROOT;
  if ($HOME and Test::More->builder->is_passing) {
    $HOME->remove;
    note "$HOME is removed";
  }
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Test

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 app_dir, app_file, app_root
=head2 requires_cpan
=head2 test_home

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
