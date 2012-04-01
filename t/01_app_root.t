use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::AppRoot;

my $app_root = WWW::Acme::CPANAuthors::AppRoot->root;
note $app_root;
isa_ok $app_root => 'Path::Extended::Dir';

my @files = qw{
  Makefile.PL
  lib/WWW/Acme/CPANAuthors.pm
  t/01_app_root.t
};

my @dirs = qw{
  lib
  lib/WWW/Acme/
  t/
};

for (@files) {
  ok $app_root->file($_)->exists, "found $_";
}

# file shortcuts
for (@files) {
  ok file($_)->exists, "found $_";
}

# directory shortcuts
for (@dirs) {
  ok dir($_)->exists, "found $_";
}

# traversal protection
for (qw{/etc/passwd c:\\windows\\notepad.exe ../ /}) {
  ok !eval { file($_) }, "died with $_";
}

done_testing;
