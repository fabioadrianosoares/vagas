package Mojolicious::Plugin::VagasHelpers;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
  my ($self, $app, $conf) = @_;

  $app->helper(servidor_host => sub {
      shift->config->{servidor}->{host} // '127.0.0.1';
    });

  $app->helper(url => sub {
      my $cfg = shift->config->{servidor};
      
      ($cfg->{scheme} // 'http') . '://' .
      ($cfg->{host} // '127.0.0.1') . 
      (exists($cfg->{port}) ? ':' . $cfg->{port} : '') .
      shift;
    });
    
  $app->helper(tratar_cookie => sub {
      my ($c, $cookies) = @_;
      my $session_id = valor_cookie($cookies);
      
      if ($session_id) {
        $c->app->log->debug('   retornou PHPSESSID: ' . $session_id);
        my $cookie = Mojo::Cookie::Response->new(name => 'PHPSESSID', value => $session_id, Expires => -1);
        $c->res->cookies($cookie);
        $c->stash({session_id => $session_id});
      }

    });   
    
  $app->helper(obter_ua => sub {
      my $c = shift;
      my $session_id = valor_cookie($c->req->cookies);
      
      my $ua = Mojo::UserAgent->new;
      $ua->transactor->name($c->req->headers->user_agent // 'Mozilla/5.0 (Windows NT 6.1; rv:25.0) Gecko/20100101 Firefox/25.0');
      
      if ($session_id) {
        $c->app->log->debug('   utilizar PHPSESSID: ' . $session_id);
        $c->stash({session_id => $session_id});
        $ua->cookie_jar->add(
          Mojo::Cookie::Response->new(
            name   => 'PHPSESSID',
            value  => $session_id,
            domain => $c->servidor_host,
            path   => '/'
          )
        );
      }
      
      # tratar os cookies quando a transacao terminar
      $ua->on(start => sub {
        my ($ua, $tx) = @_;
        $tx->on(finish => sub {
          my $tx = shift;
          $c->tratar_cookie($tx->res->cookies);
        });
      });
      
      return $ua;
    });    
     
}

sub valor_cookie {
  my $cookies = shift;
  
  foreach my $cookie (@{$cookies}) {
    if ($cookie->name eq 'PHPSESSID') {
      return $cookie->value;
    }
  }
  return undef;
}

1;
