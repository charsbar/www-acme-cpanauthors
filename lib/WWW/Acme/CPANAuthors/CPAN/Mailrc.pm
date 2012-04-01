package WWW::Acme::CPANAuthors::CPAN::Mailrc;

use strict;
use warnings;
use base 'WWW::Acme::CPANAuthors::CPAN::Index';

sub id { 'authors/01mailrc.txt' }

sub _parse {
  my ($class, $handle, $callback) = @_;

  while(my $line = $handle->getline) {
    chomp $line;
    my ($alias, $pauseid, $long) = split /\s+/, $line, 3;
    $long =~ s/^"//;
    $long =~ s/"$//;
    my ($name, $email) = $long =~ /(.*?)(?:\s*<(.+)>)?$/;

    # name may sometimes be blank
    $name = $pauseid unless defined $name and length $name;
    $callback->($pauseid, $name, $email, $line) or last;
  }
}

sub register {
  my ($class, $db) = @_;

  my @list;
  $class->parse(sub {
    my ($pauseid, $name, $email) = @_;
    push @list, [$pauseid, $name];
  });
  $db->register_authors(\@list);
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::CPAN::Mailrc

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 id
=head2 register

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
