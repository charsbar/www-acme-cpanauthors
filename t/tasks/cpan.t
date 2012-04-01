use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Test qw/requires_cpan/;
use WWW::Acme::CPANAuthors::CPAN::Mailrc;
use WWW::Acme::CPANAuthors::CPAN::Packages;

note "CPAN ROOT: ".WWW::Acme::CPANAuthors::CPAN->root;

ok(WWW::Acme::CPANAuthors::CPAN::Mailrc->file->exists, "mailrc exists");
ok(WWW::Acme::CPANAuthors::CPAN::Packages->file->exists, "packages.details exists");

my $mailrc_errors;
WWW::Acme::CPANAuthors::CPAN::Mailrc->parse(sub {
  my ($pauseid, $name, $email, $line) = @_;
  unless ($pauseid && $name && $email) {
    diag $line;
    $mailrc_errors++;
  }
});
ok !$mailrc_errors, "mailrc format";

my $packages_errors;
WWW::Acme::CPANAuthors::CPAN::Packages->parse(sub {
  my ($package, $version, $tarball, $line) = @_;
  unless ($package && defined $version && $tarball) {
    diag $line;
    $packages_errors++;
  }
});
ok !$packages_errors, "packages format";

done_testing;
