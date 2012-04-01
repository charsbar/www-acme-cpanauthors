package WWW::Acme::CPANAuthors::AcmeLibs;

use strict;
use warnings;
use WWW::Acme::CPANAuthors::AppRoot;
use lib dir('acme_libs')->path;
use WWW::Acme::CPANAuthors::CPAN;
use WWW::Acme::CPANAuthors::CPAN::Packages;
use Archive::Tar;
use Class::Unload;

sub ids {
  my $class = shift;
  my @ids;
  my $libdir = dir("acme_libs");
  unless ($libdir->exists) {
    warn "updating acme libs\n";
    $libdir->mkdir;
    $class->update;
  }
  $libdir->recurse(callback => sub {
    my $e = shift;
    return unless $e =~ /\.pm$/;
    (my $id = lc $e->relative($libdir)) =~ s/\.pm$//;
    $id =~ s{^acme/cpanauthors/}{};
    $id =~ tr{/}{_};
    push @ids, $id;
  });
  @ids;
}

sub authors {
  my ($class, $id) = @_;
  my $package = "Acme::CPANAuthors::$id";
  (my $file = "$package.pm") =~ s!::!/!g;
  $file = dir("acme_libs")->file($file)->path;
  require $file or die $!;
  my $authors = $package->authors;
  Class::Unload->unload($package);
  $authors;
}

sub register {
  my ($class, $db) = @_;

  my $libdir = dir("acme_libs");
  unless ($libdir->exists) {
    warn "updating acme libs\n";
    $libdir->mkdir;
    $class->update;
  }

  $libdir->recurse(callback => sub {
    my $e = shift;
    return unless $e =~ /\.pm$/;
    my $file = $e->relative($libdir);
    (my $package = $file) =~ s/\.pm$//;
    $package =~ s!/!::!g;
    (my $id = lc $package) =~ s!^acme::cpanauthors::!!;
    $id =~ s!::!_!g;

    require $file or die $!;
    my $version = $package->VERSION;
    my $authors = $package->authors;

    $db->register_package($id, $package, $version, $authors);

    Class::Unload->unload($package);
  });
}

sub update {
  my $class = shift;

  my $tmpdir = dir("tmp/lib")->mkdir;
  my $libdir = dir("acme_libs");

  my %seen;
  my @files;
  WWW::Acme::CPANAuthors::CPAN::Packages->parse(sub {
    my ($package, $version, $tarball, $line) = @_;

    return 1 unless $package =~ /^Acme::CPANAuthors/;
    return 1 if $package =~ m{::(?:Not|Utils|Register|You|Search)};

    (my $libfile = "$package.pm") =~ s{::}{/}g;
    $libfile = $libdir->file($libfile)->relative;

    {
      no warnings 'redefine';
      if (eval "require '$libfile'; 1") {
        my $installed_version = $package->VERSION || '';
        Class::Unload->unload($package);

        return 1 if $version && $version eq $installed_version;
        warn "$package: (listed) $version (installed) $installed_version\n" if $installed_version;
      }
    }

    return 1 if $seen{$tarball}++;

    my $archive = cpanfile("authors/id/$tarball");
    unless ($archive->exists) {
      # maybe syncing, maybe error
      warn "$tarball not found\n";
      return 1;
    }
    my $tar = Archive::Tar->new($archive->path);
    for my $file ($tar->list_files) {
      next unless $file =~ m{.*lib/(Acme/CPANAuthors/.+\.pm)$};
      next if $file =~ m{/(?:t|Not|Utils|Register|You|Search)(?:/|\.pm$)};

      # Ignore utilities, jokes, and those depend on what you have.
      my $path = $1;
      $tar->extract_file($file => $tmpdir->file($path)->path);
      push @files, $file;
    }
    return if $package =~ /^A['d'..'z']/; # shortcut
    return 1;
  });
  if (@files) {
    $libdir->remove; # to clear old files
    $tmpdir->move_to($libdir);
  }
  @files;
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::AcmeLibs

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 authors

=head2 ids

=head2 register

=head2 update

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
