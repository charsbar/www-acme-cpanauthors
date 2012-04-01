package WWW::Acme::CPANAuthors::DB::CPANTS::Schema;

use strict;
use warnings;

# too long to insert into ::DB::CPANTS
sub schema { return <<'SCHEMA';
create table author (
  id integer primary key not null,
  pauseid text,
  name text,
  email text,
  average_kwalitee numeric,
  num_dists integer not null,
  rank integer not null,
  prev_av_kw numeric,
  prev_rank integer not null,
  average_total_kwalitee numeric
);

create index auth_av on author (average_kwalitee);

create index auth_num on author (num_dists);

create index auth_pav on author (prev_av_kw);

create index auth_prank on author (prev_rank);

create index auth_rank on author (rank);

create unique index author_pauseid_key on author (pauseid);

create table dist (
  id integer primary key not null,
  run integer,
  dist text,
  package text,
  vname text,
  author integer,
  version text,
  version_major text,
  version_minor text,
  extension text,
  extractable integer not null,
  extracts_nicely integer not null,
  size_packed integer not null,
  size_unpacked integer not null,
  released timestamp without time zone,
  files integer not null,
  files_list text,
  dirs integer not null,
  dirs_list text,
  symlinks integer integer not null,
  symlinks_list text,
  bad_permissions integer not null,
  bad_permissions_list text,
  file_makefile_pl integer not null,
  file_build_pl integer not null,
  file_readme text,
  file_manifest integer not null,
  file_meta_yml integer not null,
  file_signature integer not null,
  file_ninja integer not null,
  file_test_pl integer not null,
  file_changelog text,
  dir_lib integer not null,
  dir_t integer not null,
  dir_xt integer not null,
  broken_module_install text not null,
  mi_auto_install_used text not null,
  manifest_matches_dist integer not null,
  buildfile_executable integer not null,
  license text,
  metayml_is_parsable integer not null,
  file_license integer not null,
  needs_compiler integer not null,
  got_prereq_from text,
  is_core integer not null,
  file__build integer not null,
  file_build integer not null,
  file_makefile integer not null,
  file_blib integer not null,
  file_pm_to_blib integer not null,
  stdin_in_makefile_pl integer not null,
  stdin_in_build_pl integer not null,
  external_license_file text,
  file_licence text,
  licence_file text,
  license_file text,
  license_type text,
  no_index text,
  ignored_files_list text,
  license_in_pod integer not null,
  license_from_yaml text,
  license_from_external_license_file text,
  test_files_list text
);

create index dist_auth on dist (author);

create unique index dist_dist_key on dist (dist);

create unique index dist_package_key on dist (package);

create unique index dist_vname_key on dist (vname);

create table error (
  id integer primary key,
  dist integer,
  prereq_matches_use text,
  build_prereq_matches_use text,
  manifest_matches_dist text,
  metayml_conforms_to_known_spec text,
  cpants text,
  no_pod_errors text,
  metayml_is_parsable text,
  no_generated_files text not null,
  has_version_in_each_file text,
  no_stdin_for_prompting text,
  easily_repackageable_by_fedora text,
  easily_repackageable_by_debian text,
  easily_repackageable text,
  metayml_conforms_spec_current text,
  no_large_files text,
  has_license_in_source_file text,
  has_no_patches_in_debian text,
  latest_version_distributed_by_debian text,
  has_no_bugs_reported_in_debian text
);

create table history_author (
  id integer primary key not null,
  run integer,
  author integer,
  average_kwalitee numeric,
  num_dists integer,
  rank integer
);

create table history_dist (
  id integer primary key,
  run integer,
  distname text,
  version text,
  kwalitee numeric not null,
  dist integer
);

create table kwalitee (
  id integer primary key not null,
  dist integer,
  abs_kw integer not null,
  abs_core_kw integer not null,
  kwalitee numeric not null,
  rel_core_kw numeric not null,
  extractable integer not null,
  extracts_nicely integer not null,
  has_version integer not null,
  has_proper_version integer not null,
  no_cpants_errors integer not null,
  has_readme integer not null,
  has_manifest integer not null,
  has_meta_yml integer not null,
  has_buildtool integer not null,
  has_changelog integer not null,
  no_symlinks integer not null,
  has_tests integer not null,
  proper_libs integer not null,
  is_prereq integer not null,
  use_strict integer not null,
  use_warnings integer not null,
  has_test_pod integer not null,
  has_test_pod_coverage integer not null,
  no_pod_errors integer not null,
  has_working_buildtool integer not null,
  manifest_matches_dist integer not null,
  has_example integer not null,
  buildtool_not_executable integer not null,
  has_humanreadable_license integer not null,
  metayml_is_parsable integer not null,
  metayml_conforms_spec_current integer not null,
  metayml_has_license integer not null,
  metayml_conforms_to_known_spec integer not null,
  has_license integer not null,
  prereq_matches_use integer not null,
  build_prereq_matches_use integer not null,
  no_generated_files integer not null,
  run integer,
  has_version_in_each_file integer not null,
  has_tests_in_t_dir integer not null,
  no_stdin_for_prompting integer not null,
  easily_repackageable_by_fedora integer not null,
  easily_repackageable_by_debian integer not null,
  easily_repackageable integer not null,
  fits_fedora_license integer not null,
  metayml_declares_perl_version integer not null,
  no_large_files integer,
  has_separate_license_file integer not null,
  has_license_in_source_file integer not null,
  metayml_has_provides integer not null,
  uses_test_nowarnings integer not null,
  latest_version_distributed_by_debian integer not null,
  has_no_bugs_reported_in_debian integer not null,
  has_no_patches_in_debian integer not null,
  distributed_by_debian integer not null,
  has_better_auto_install integer not null
);

create table modules (
  id integer primary key,
  dist integer,
  module text,
  file text,
  in_lib integer not null,
  in_basedir integer not null,
  is_core integer not null
);

create index modules_basedir on modules (in_basedir);

create index modules_core on modules (is_core);

create index modules_dist on modules (dist);

create index modules_lib on modules (in_lib);

create table prereq (
  id integer primary key,
  dist integer,
  requires text,
  version text,
  in_dist integer,
  is_prereq integer not null,
  is_build_prereq integer not null,
  is_optional_prereq integer not null
);

create index prereq_dist on prereq (dist);

create index prereq_in_dist on prereq (in_dist);

create index prereq_is_buildreq on prereq (is_build_prereq);

create index prereq_is_optreq on prereq (is_optional_prereq);

create index prereq_is_req on prereq (is_prereq);

create index prereq_requires on prereq (requires);

create table run (
  id integer primary key not null,
  mcanalyse_version text,
  mcprocess_version text,
  available_kwalitee integer not null,
  total_kwalitee integer not null,
  date timestamp without time zone,
  stop timestamp without time zone
);

create table uses (
  id integer primary key,
  dist integer,
  module text,
  in_dist integer,
  in_code integer not null,
  in_tests integer not null
);

create index uses_dist on uses (dist);

create index uses_in_code on uses (in_code);

create index uses_in_dist on uses (in_dist);

create index uses_in_tests on uses (in_tests);

create index uses_modules on uses (modules);

SCHEMA
}

1;

__END__

=head1 NAME

WWW::Acme::CPANAuthors::DB::CPANTS::Schema

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 schema

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
