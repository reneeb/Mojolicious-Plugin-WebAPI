package
     ApiTest;
use Mojo::Base 'Mojolicious';

use ApiTest::Schema;
use File::Basename;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  my $db     = dirname(__FILE__) . '/../test.db';
  my $schema = ApiTest::Schema->connect('DBI:SQLite:' . $db);

  # Normal route to controller
  $r->get('/')->to('example#welcome');

  my $auth  = $self->routes->under('/')->to( 'auth#test' );
  my $route = $auth->route('/api/v0/');

  $self->plugin('WebAPI' => {
    schema => $schema,
    route  => $route,

    resource_opts => {
      resource_default_args => {
        http_auth_type => 'none',
        #base_uri       => $route->to_string,
      },
    },
  });
}

1;
