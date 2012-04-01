use strict;
use warnings;
use Test::More;
use WWW::Acme::CPANAuthors::AppRoot;
use WWW::Acme::CPANAuthors::Test qw/app_root/;

ok app_root->file('Makefile.PL')->exists, "Makefile.PL exists under app_root";
isnt app_root => WWW::Acme::CPANAuthors::AppRoot->root, "::AppRoot->root is modified";
ok !file('Makefile.PL')->exists, "Makefile.PL does not exist under a modified app root (test home)" or note file('Makefile.PL');

done_testing;
