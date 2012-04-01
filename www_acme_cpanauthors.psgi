#!/usr/bin/env perl

use strict;
use warnings;
use lib "lib";
use Mojolicious::Lite;
use String::Random 'random_regex';
use WWW::Acme::CPANAuthors::Pages;

$ENV{MOJO_REVERSE_PROXY} = 1;

app->mode('production');
app->log->level('error');
app->secret(random_regex('\w{40}'));

# ------------ For Browsers -----------------

get '/' => sub {
  my $self = shift;
  my $data = load_page('Home') or return $self->render_not_found;
  $self->stash($data);
} => 'home';

get '/modules' => sub {
  my $self = shift;
  my $data = load_page('Modules') or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'modules';

get '/resources' => 'resources';

get '/for/:class' => sub {
  my $self = shift;
  my $class = $self->stash('class');
  my $data = load_page('For', $class) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'for';

# - private interest -

get '/yapcasia/:year' => sub {
  my $self = shift;
  my $year = $self->stash('year');
  my $data = load_page('YapcAsia', $year) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'yapcasia';

get '/yapcasia' => sub {
  my $self = shift;
  my $data = load_page('YapcAsia', 'all') or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'yapcasia';

# - CPANTS (Kwalitee) port -

get '/author/:id' => sub {
  my $self = shift;
  my $id = uc $self->param('id');
  my $data = load_page('Author', $id) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
  $self->stash(requires_highcharts => 1);
} => 'author';

get '/authors' => sub {
  my $self = shift;
  $self->stash(authors => []);
} => 'authors';

post '/authors' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Authors', $name);
  if (@{$data->{authors}} == 1) {
    $self->redirect_to('/author/'.$data->{authors}[0]{pause_id});
    return;
  }
  $self->stash(name => $name);
  $self->stash($data);
} => 'authors';

get '/dist/:distname' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Overview', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_highcharts => 1);
  $self->stash(requires_tablesorter => 1);
} => 'dist_overview';

get '/dist/:distname/prereq' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Prereq', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'dist_prereq';

get '/dist/:distname/used_by' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::UsedBy', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'dist_usedby';

get '/dist/:distname/provides' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Provides', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'dist_provides';

get '/dist/:distname/metadata' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Metadata', $name) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'dist_metadata';

get '/dists' => sub {
  my $self = shift;
  $self->stash(dists => []);
} => 'dists';

post '/dists' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Dists', $name);
  if (@{$data->{dists}} == 1) {
    $self->redirect_to('/dist/'.$data->{dists}[0]{dist});
    return;
  }
  $self->stash(name => $name);
  $self->stash($data);
} => 'dists';

get '/ranking' => 'ranking';

get '/ranking/five_or_more' => sub {
  my $self = shift;
  my $page = $self->param('page') || 1;
  my $data = load_page('Ranking::FiveOrMore', $page) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'ranking_five_or_more';

get '/ranking/less_than_five' => sub {
  my $self = shift;
  my $page = $self->param('page') || 1;
  my $data = load_page('Ranking::LessThanFive', $page) or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'ranking_less_than_five';

get '/ranking/hall_of_fame' => sub {
  my $self = shift;
  my $data = load_page('Ranking::HallOfFame') or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_tablesorter => 1);
} => 'ranking_hall_of_fame';

get '/kwalitee' => sub {
  my $self = shift;
  my $data = load_page('Kwalitee') or return $self->render_not_found;
  $self->stash($data);
  $self->stash(requires_highcharts => 1);
  $self->stash(requires_tablesorter => 1);
} => 'kwalitee_overview';

# ------------ API -----------------

under '/api' => sub {
  my $self = shift;

  return unless $self->req->is_xhr;
  # XXX: want some token?

  return 1;
};

post '/authors' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Authors', $name);
  $self->render(json => $data);
};

post '/dists' => sub {
  my $self = shift;
  my $name = $self->param('name');
  my $data = load_page('Dists', $name);
  $self->render(json => $data);
};

get '/chart/author/:id' => sub {
  my $self = shift;
  my $id = $self->param('id');
  my $data = load_page('Author::Chart', $id);
  $self->render(json => $data);
};

get '/chart/dist/:distname' => sub {
  my $self = shift;
  my $name = $self->param('distname');
  my $data = load_page('Dist::Chart', $name);
  $self->render(json => $data);
};

get '/chart/kwalitee/overview' => sub {
  my $self = shift;
  my $data = load_page('Kwalitee::Chart::Overview');
  $self->render(json => $data);
};

app->start();
