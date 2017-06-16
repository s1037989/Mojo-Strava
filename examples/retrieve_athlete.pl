use 5.010;
use Mojo::Strava;
use Data::Dumper;

my $strava = Mojo::Strava->new(access_token => '...');
say Dumper($strava->athletes('retrieve')->result->json);
say Dumper($strava->athletes([retrieve => {id => '...'}])->result->json);
