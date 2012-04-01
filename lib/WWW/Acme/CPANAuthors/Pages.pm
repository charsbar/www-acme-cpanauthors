package WWW::Acme::CPANAuthors::Pages;

use strict;
use warnings;
use Module::Find qw/findallmod/;
use Sub::Install qw/reinstall_sub/;

our %LOADED;

sub import {
  my $class = shift;
  my $caller = caller;
  for my $module (findallmod 'WWW::Acme::CPANAuthors::Page') {
    eval "require $module; 1" or do { warn $@; next; };	
    $LOADED{$module} = 1;
  }
  reinstall_sub({ into => $caller, code => 'load_page' });
}

sub load_page {
  my $id = shift;
  my $package = "WWW::Acme::CPANAuthors::Page::".$id;
  $package->load_data(@_);
}

sub loaded { keys %LOADED }

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::Pages

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 load_page
=head2 loaded

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
