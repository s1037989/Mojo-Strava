use Mojo::Base -strict;

BEGIN { $ENV{MOJO_REACTOR} = 'Mojo::Reactor::Poll'; $ENV{MOJO_LOG_LEVEL} = 'info' }

use Test::More;

use Mojo::IOLoop;
use Mojolicious::Lite;
use Test::Mojo;

use Mojo::JSON qw/true false/;
use Mojo::Strava;

get '/athlete' => sub {
  my $c = shift;
  $c->render(json => {
    "id" => 227615,
    "resource_state" => 2,
    "firstname" => "John",
    "lastname" => "Applestrava",
    "profile_medium" => "http://pics.com/227615/medium.jpg",
    "profile" => "http://pics.com/227615/large.jpg",
    "city" => "San Francisco",
    "state" => "CA",
    "country" => "United States",
    "sex" => "M",
    "friend" => undef,
    "follower" => "accepted",
    "premium" => true,
    "created_at" => "2011-03-19T21:59:57Z",
    "updated_at" => "2013-09-05T16:46:54Z"
  });
};

get '/athletes/:id' => sub {
  my $c = shift;
  $c->render(json => {
    "id" => $c->param('id'),
    "resource_state" => 2,
    "firstname" => "John",
    "lastname" => "Applestrava",
    "profile_medium" => "http://pics.com/227615/medium.jpg",
    "profile" => "http://pics.com/227615/large.jpg",
    "city" => "San Francisco",
    "state" => "OR",
    "country" => "United States",
    "sex" => "M",
    "friend" => undef,
    "follower" => "accepted",
    "premium" => true,
    "created_at" => "2011-03-19T21:59:57Z",
    "updated_at" => "2013-09-05T16:46:54Z"
  });
};

my $t = Test::Mojo->new;
my $strava = Mojo::Strava->new(access_token => '123', base_url => $t->ua->server->url =~ s/\/$//r, _ua => $t->ua);

is $strava->access_token, '123', 'right access token';
is $strava->athletes('retrieve')->result->json('/id'), '227615', 'right id';
is $strava->athletes([retrieve => {id => 123}])->result->json('/id'), '123', 'right id';

done_testing;
