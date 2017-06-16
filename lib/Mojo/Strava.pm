package Mojo::Strava;
use Mojo::Base -base;

our $VERSION = '0.01';

use Mojo::UserAgent;
use Mojolicious::Routes::Pattern;

has base_url     => 'https://www.strava.com/api/v3/';
has access_token => sub { die 'missing access_token' };
has _ua          => sub { Mojo::UserAgent->new };

# $strava->athletes([retrieve => {id => 123}])
# $strava->athletes('retrieve')
# $strava->athletes('update' => {name => 'sam'})
# $strava->athletes('zones')
*athlete = \&athletes;
sub athletes {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve         => 'athletes/:id'],
    [retrieve         => 'athlete'],
    [update           => 'athlete' => 'put'],
    [zones            => 'athlete/zones'],
    ['totals|stats'   => 'athlete/:id/stats'],
    ['kom|qom|cr    ' => 'athlete/:id/koms'],
    [friends          => 'athletes/:id/friends'],
    [friends          => 'athlete/friends'],
    [followers        => 'athletes/:id/followers'],
    [followers        => 'athlete/followers'],
    ['both-following' => 'athletes/:id/both-following'],
    [activities       => 'athlete/activities'],
    [clubs            => 'athlete/clubs'],
    [routes           => 'athlete/:id/routes'],
    [segments         => 'athlete/:id/segments/starred'],
  );
}

# $strava->activities('create')
# $strava->activities([retrieve => {id => 123}])
# $strava->activities(['update' => {id => 123}] => {name => 'sam'})
*activity = \&activities;
sub activities {
  my $self = shift;
  $self->_match_action(\@_,
    [create   => 'activities' => 'post'],
    [retrieve => 'activities/:id'],
    [update   => 'activities/:id' => 'put'],
    [list     => 'athlete/activities'],
    [friends  => 'activities/following'],
    [related  => 'activities/:id/related'],
    [zones    => 'activities/:id/zones'],
    [laps     => 'activities/:id/laps'],
    [comments => 'activities/:id/comments'],
    [kudo     => 'activities/:id/kudos'],
    [photos   => 'activities/:id/photos'],
  );
}

*club = \&clubs;
sub clubs {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve      => 'clubs/:id'],
    [announcements => 'clubs/:id/announcements'],
    [list          => 'athlete/clubs'],
    [members       => 'clubs/:id/members'],
    [admins        => 'clubs/:id/admins'],
    [activities    => 'clubs/:id/activities'],
    [join          => 'clubs/:id/join' => 'post'],
    [leave         => 'clubs/:id/leave' => 'post'],
  );
}

*event = \&events;
sub events {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve => 'group_events/:id'],
    [list     => 'clubs/:club_id/group_events'],
    [join     => 'group_events/:id/rsvps' => 'post'],
    [leave    => 'group_events/:id/rsvps' => 'delete'],
    [delete   => 'group_events/:id' => 'delete'],
    [joined   => 'group_events/:id/athletes'],
  );
}

sub gear {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve => 'gear/:id'],
  );
}

*route = \&routes;
sub routes {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve => 'routes/:route_id'],
    [list     => 'athletes/:id/routes'],
    [stream    => 'routes/:id/streams'],
  );
}

*race = \&races;
sub races {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve => 'running_races/:id'],
    [list     => 'running_races/:year'],
  );
}

*segment = \&segments;
sub segments {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve  => 'segments/:id'],
    [starred   => 'segments/starred'],
    [star      => 'segments/:id/starred' => 'put'],
    [efforts   => 'segments/:id/all_efforts'],
    ['effort$' => 'segment_efforts/:id'],
    [leader    => 'segments/:id/leaderboard'],
    [explorer  => 'segments/explore'],
    [stream    => 'segments/:id/streams/:types'],
  );
}

*segment_effort = \&segment_efforts;
sub segment_efforts {
  my $self = shift;
  $self->_match_action(\@_,
    [retrieve  => 'segment_efforts/:id'],
    [stream    => 'segment_efforts/:id/streams/:types'],
  );
}

*stream = \&streams;
sub streams {
  my $self = shift;
  $self->_match_action(\@_,
    [activity => 'activities/:id/streams/:types'],
    [effort   => 'segment_efforts/:id/streams/:types'],
    [segment  => 'segments/:id/streams/:types'],
    [route    => 'routes/:id/streams'],
  );
}

*upload = \&uploads;
sub uploads {
  my $self = shift;
  $self->_match_action(\@_,
    [activity => 'uploads' => 'post'],
    [status   => 'uploads/:id'],
  );
}

*webhook = \&webhooks;
sub webhooks {
  my $self = shift;
  $self->_match_action(\@_,
    [create => 'push_subscriptions' => 'post'],
    [list   => 'push_subscriptions'],
    [delete => 'push_subscriptions:/id' => 'delete'],
  );
}

sub get     { shift->_tx(get    => @_) }
sub post    { shift->_tx(post   => @_) }
sub put     { shift->_tx(put    => @_) }
sub delete  { shift->_tx(delete => @_) }

#*athlete = \&athletes;
#sub athletes {
#  my ($self, $action, @cb) = (shift, shift, ref $_[-1] eq 'CODE' ? pop @_ : ());
#  my $match;
#  $_ = $action;
#  ($_, $match) = (shift @$action, shift @$action) if ref $action eq 'ARRAY' && ref $action->[1] eq 'HASH';
#  my $url = Mojo::URL->new($self->base_url);
#  my $method = 'get';
#  if    (/retrieve/       && $match) { $url->path('athletes/:id')                               }
#  elsif (/retrieve/                ) { $url->path('athlete')                                    }
#  elsif (/update/                  ) { $url->path('athlete')                and $method = 'put' }
#  elsif (/zones/                   ) { $url->path('athlete/zones')                              }
#  elsif (/totals|stats/   && $match) { $url->path('athlete/:id/stats')                          }
#  elsif (/kom|qom|cr/     && $match) { $url->path('athlete/:id/koms')                           }
#  elsif (/friends/        && $match) { $url->path('athletes/:id/friends')                       }
#  elsif (/friends/                 ) { $url->path('athlete/friends')                            }
#  elsif (/followers/      && $match) { $url->path('athletes/:id/followers')                     }
#  elsif (/followers/               ) { $url->path('athlete/followers')                          }
#  elsif (/both-following/ && $match) { $url->path('athletes/:id/followers')                     }
#  my $pattern = Mojolicious::Routes::Pattern->new($url->path);
#  return $self->$method($pattern->render($match//{}) => @_ => @cb);
#}

sub _match_action {
  my ($self, $args) = (shift, shift);
  my @cb = ref $args->[-1] eq 'CODE' ? pop @$args : ();
  my ($req, $params) = (shift @$args, undef);
  ($req, $params) = (shift @$req, shift @$req) if ref $req eq 'ARRAY' && ref $req->[1] eq 'HASH';
  my $url = Mojo::URL->new($self->base_url);
  foreach my $qmm ( @_ ) {
    my ($qr, $match, $method) = @$qmm;
    next unless $req =~ /$qr/;
    my $need_match = $match =~ /:(\w+)/;
    next unless ($params && $need_match) || (!$params && !$need_match);
    $method ||= 'get';
    $url->path($match);
    my $pattern = Mojolicious::Routes::Pattern->new($url->path);
    #warn Data::Dumper::Dumper([$url->path, $method, $params, $args, @cb]);
    return $self->$method($pattern->render($params//{}) => @$args => @cb);
  }
}

sub _tx {
  my ($self, $method, $path, $cb) = (shift, shift, shift, ref $_[-1] eq 'CODE' ? pop @_ : undef);
  my $url = Mojo::URL->new($self->base_url)->path($path);
  unshift @_, {} unless ref $_[0] eq 'HASH';
  $_[0]->{Authorization} = sprintf 'Bearer %s', $self->access_token unless exists $_[0]->{Authorization};
  #warn Data::Dumper::Dumper([$method, $url, @_]);
  if ( $cb ) {
    $self->_ua->$method($url => @_ => sub {
      my ($ua, $tx) = @_;
      $cb->($ua, $tx);
    });
  } else {
    my $tx = $self->_ua->$method($url => @_);
    return $tx;
  }
}

1;

=encoding utf8

=head1 NAME

Mojo::Strava - A simple interface to the Strava API

=head1 SYNOPSIS

  use Mojo::Strava;

  my $strava = Mojo::Strava->new(access_token => '...');
  say $strava->get('/athlete')->result->json('/id');
  say $strava->athlete('clubs')->result->json('/0/name');
  say $strava->athlete([koms => {id => 123}])->result->json('/0/name');
  
=head1 DESCRIPTION

A simple interface to the Strava API.

The methods provided by this module offer no data validation or error handling.
No built-in support for paging. Pull requests welcome!

The API reference guide is available at L<http://strava.github.io/api/v3>

So what does this module do? It makes building the API URL easier and includes
the access token in the Authorization header on all requests. So, not much. But
it does offer a little bit of sugar, and, hopefully eventually, some data
validation, error handling, and built-in support for paging.

=head1 ATTRIBUTES

L<Mojo::Strava> implements the following attributes.

=head2 base_url

  my $base_url = $cf->base_url;
  $cf          = $cf->base_url($url);

The base URL for the Strava API, defaults to https://api.callfire.com/v2.

=head2 access_token

  my $access_token = $strava->access_token;
  $strava          = $strava->access_token($access_token);

The access_token for the Strava API. Generate an access token API credential on
Strava's API access page.  Read more at the Access section of the
API Reference at L<http://strava.github.io/api/#access>.

=head1 METHODS

L<Mojo::Strava> inherits all methods from L<Mojo::Base> and implements the
following new ones.

=head2 activities

=head2 activity

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * create
  * retrieve [id]
  * update id
  * list
  * friends
  * related id
  * zones id
  * laps id
  * comments id
  * kudoers id
  * photos id

=head2 athlete

=head2 athletes

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve [id]
  * update
  * zones
  * totals|stats id
  * kom|qom|cr id
  * friends [id]
  * followers [id]
  * both-following id
  * activities
  * clubs
  * routes id
  * segments id

=head2 club

=head2 clubs

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve id
  * announcements id
  * list
  * members id
  * admins id
  * activities id
  * join id
  * leave id

=head2 delete

  # Blocking
  my $tx = $cf->del('/rest/endpoint', %args);
  say $tx->result->body;
  
  # Non-blocking
  $cf->del('/rest/endpoint', %args => sub {
    my ($ua, $tx) = @_;
    say $tx->result->body;
  });

A RESTful DELETE method. Accepts the same arguments as L<Mojo::UserAgent> with
the exception that the URL is built starting from the L<base_url> and the HTTP
Authorization header for the access token is automatically applied on each
request.

See the Strava API Reference at L<http://strava.github.io/api/v3> for the HTTP
methods, URL path, and parameters to supply for each desired action.

=head2 event

=head2 events

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve id
  * list
  * join id
  * leave id
  * delete id
  * joined id

=head2 gear

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve id

=head2 get

  # Blocking
  my $tx = $cf->get('/rest/endpoint', %args);
  say $tx->result->body;
  
  # Non-blocking
  $cf->get('/rest/endpoint', %args => sub {
    my ($ua, $tx) = @_;
    say $tx->result->body;
  });

A RESTful GET method. Accepts the same arguments as L<Mojo::UserAgent> with
the exception that the URL is built starting from the L<base_url> and the HTTP
Authorization header for the access token is automatically applied on each
request.

See the Strava API Reference at L<http://strava.github.io/api/v3> for the HTTP
methods, URL path, and parameters to supply for each desired action.

=head2 post

  # Blocking
  my $tx = $cf->post('/rest/endpoint', %args);
  say $tx->result->body;
  
  # Non-blocking
  $cf->post('/rest/endpoint', %args => sub {
    my ($ua, $tx) = @_;
    say $tx->result->body;
  });

A RESTful POST method. Accepts the same arguments as L<Mojo::UserAgent> with
the exception that the URL is built starting from the L<base_url> and the HTTP
Authorization header for the access token is automatically applied on each
request.

See the Strava API Reference at L<http://strava.github.io/api/v3> for the HTTP
methods, URL path, and parameters to supply for each desired action.

=head2 put

  # Blocking
  my $tx = $cf->put('/rest/endpoint', %args);
  say $tx->result->body;
  
  # Non-blocking
  $cf->put('/rest/endpoint', %args => sub {
    my ($ua, $tx) = @_;
    say $tx->result->body;
  });

A RESTful PUT method. Accepts the same arguments as L<Mojo::UserAgent> with
the exception that the URL is built starting from the L<base_url> and the HTTP
Authorization header for the access token is automatically applied on each
request.

See the Strava API Reference at L<http://strava.github.io/api/v3> for the HTTP
methods, URL path, and parameters to supply for each desired action.

=head2 race

=head2 races

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve id
  * list year

=head2 route

=head2 routes

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve route_id
  * list id
  * stream id

=head2 segment

=head2 segments

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve id
  * starred
  * star id
  * efforts id
  * effort id
  * leader id
  * explorer
  * stream id,types

=head2 segment_effort

=head2 segment_efforts

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * retrieve id
  * stream id,types

=head2 stream

=head2 streams

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * activity id,types
  * effort id,types
  * segment id,types
  * route id

=head2 upload

=head2 uploads

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * activity
  * status

=head2 webhook

=head2 webhooks

  my $tx = $strava->activities('action');
  my $tx = $strava->activities([action => $hash]);

  Available actions and their required parameters:
  * create
  * list
  * delete id

=head1 SEE ALSO

L<http://strava.com>

=cut
