use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME          => 'WWW::Acme::CPANAuthors',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/WWW/Acme/CPANAuthors.pm',
  ABSTRACT_FROM => 'lib/WWW/Acme/CPANAuthors.pm',
  PREREQ_PM => {
    'Acme::CPANAuthors'      => '0.19', # suppress warnings
    'Archive::Tar'           => 0,
    'CLI::Dispatch'          => '0.12',
    'Class::Unload'          => 0,
    'Compress::Zlib'         => 0,
    'DBD::SQLite'            => '1.36_01', # profile/trace
    'DBI'                    => '1.609',   # sqlite_ prefix
    'Exporter::Lite'         => 0,
    'IO::Uncompress::Gunzip' => 0,
    'JSON::XS'               => 0,
    'List::Util'             => 0,
    'Log::Dump'              => '0.12',
    'Module::Find'           => 0,
    'Mojolicious'            => 0,
    'Path::Extended'         => 0,
    'Plack'                  => '0.99',
    'LWP::UserAgent'         => 0,
    'String::CamelCase'      => 0,
    'String::Random'         => 0,
    'Sub::Install'           => 0,
    'Test::More'             => '0.88',
    'Test::UseAllModules'    => '0.10',
    'Time::Piece'            => 0,
    'URI'                    => 0,
    'Web::Scraper'           => 0,
  },
  ($ExtUtils::MakeMaker::VERSION >= 6.31
    ? ( LICENSE => 'perl' )
    : ()
  ),
  test => { TESTS => 't/*.t t/*/*.t' },
);
