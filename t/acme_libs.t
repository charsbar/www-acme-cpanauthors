use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::Test qw/requires_cpan/;
use WWW::Acme::CPANAuthors::AppRoot;
use WWW::Acme::CPANAuthors::AcmeLibs;

my @files = WWW::Acme::CPANAuthors::AcmeLibs->update;
ok @files, "successfully updated";
ok grep(/Japanese/, @files), "updated ::Japanese";
note explain \@files;

my @excluded = qw{
  Acme-CPANAuthors-([\d.]+)/
  /t/
  /Not.pm
  /Search.pm
  /You/re_using.pm	
};

for my $path (@excluded) {
  ok !(grep /$path/, @files), "$path is excluced";
}

@files = ();
@files = WWW::Acme::CPANAuthors::AcmeLibs->update;
ok @files, "successfully updated";
note explain \@files;

done_testing;
