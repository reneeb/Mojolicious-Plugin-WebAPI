package Mojolicious::Plugin::WebAPI;

# ABSTRACT: Mojolicious::Plugin::WebAPI - mount WebAPI::DBIC in your Mojolicious app

use Mojo::Base 'Mojolicious::Plugin';

use WebAPI::DBIC::WebApp;
use Mojolicious::Plugin::WebAPI::Proxy;
 
our $VERSION = '0.01';
 
sub register {
    my ($self, $app, $conf) = @_;

    my $schema = delete $conf->{schema};
    my $route  = delete $conf->{route};

    my $psgi_app = WebAPI::DBIC::WebApp->new({
        schema => $schema,
    })->to_psgi_app;

    $route->detour(
        app => Mojolicious::Plugin::WebAPI::Proxy->new(
            app  => $psgi_app,
            base => $route->to_string,
        ),
    );
}

1;
__END__

=encoding utf8

=head1 SYNOPSIS

  # load DBIx::Class schema
  use MyApp::Schema;
  my $schema = MyApp::Schema->connect('DBI:SQLite:test.db');
  
  # create base route for api
  my $route = $self->routes->route('/api/v0');
  $self->plugin('WebAPI' => {
      schema => $schema,
      route  => $route,
  });



  # now with a route that can check for authentication
  use MyApp::Schema;
  my $schema = MyApp::Schema->connect('DBI:SQLite:test.db');
  
  # create base route for api
  my $auth  = $self->routes->auth('/')->to('auth#test');
  my $route = $auth->route('/api/v0');
  $self->plugin('WebAPI' => {
      schema => $schema,
      route  => $route,
  });


=head1 DESCRIPTION

This is just the glue to mount the webapi into your application. The
hard work is done by L<WebAPI::DBIC>. The code for C<Proxy.pm> is
mostly from L<Mojolicious::Plugin::MountPSGI>.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
