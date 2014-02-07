package ParseVagas;

use Mojo::Base -strict;
use Mojo::Util qw(trim html_unescape url_unescape);
use utf8;

sub fazer {
  my $html = shift;

  my $retorno = {op => []};
  
  if ($html =~ /informe o codigo corretamente/) {
    $retorno->{tv} = '0';
    $retorno->{erro} = 'Verificacao incorreta';
  }
  
  if ($html =~ /name="tv" value="(\d+)"/) {
    $retorno->{tv} = $1;
  } else {
    $retorno->{tv} = '0';
  }

  if ($html =~ /name="pag" value="(\d+)"/) {
    $retorno->{proxima} = $1;
  } else {
    $retorno->{proxima} = '';
  }

  if ($html =~ /name="keyw" value="([^"]+)"/) {
    $retorno->{keyw} = $1;
  } else {
    $retorno->{keyw} = '';
  }
  
  my @partes = split /<hr size="6" noshade>/, $html;

  foreach my $parte (@partes) {
    if ($parte =~ /Enviar curriculum para/) {
      # esta com cara de oportunidade :)
      my ($cidade, $estado, $data, $titulo, $descricao, $empresa, $email, $codigo);
      
      if ($parte =~ /#0000EE">([^<]+) - ([^<]+) - ([^<]+)</) {
        ($cidade, $estado, $data) = ($1, $2, $3);
      } else {
        ($cidade, $estado, $data) = ('', '', '');
      }

      if ($parte =~ /<B><FONT SIZE=\+1>([^<]+)</) {
        $titulo = trim $1;
      } else {
        $titulo = '';
      }
      
      if ($parte =~ /\n <br>(.+?)<\/PRE>/ ) {
        $descricao = $1;
      } else {
        $descricao = '';
        if ($parte =~ /<PRE>(.+?)<\/PRE>/s ) {
          $descricao = $1;
        } else {
          $descricao = '';
        }
      }
      $descricao =~ s/<br>/\n/isg;
      $descricao =~ s/</&lt;/g;
      $descricao =~ s/>/&gt;/g;
      $descricao =~ s/\n/<br \/>/sg;
      $descricao =~ s/\r//sg;
      $descricao =~ s/^(<br \/>\s*)+//sg;
      $descricao =~ s/\s*(<br \/>\s*)+$//sg;
        
      if ($parte =~ /Empresa \.+:\s+([^<]+)</) {
        $empresa = trim $1;
      } else {
        $empresa = '';
      }

      if ($parte =~ /A HREF="([^"\?]+)/) {
        my $auxi = url_unescape(html_unescape($1));
        $auxi =~ s/&#046/\./g;
        $email = ($auxi =~ /mailto:(.+)/) ? $1 : '';
      } else {
        $email = '';
      }
      
      if ($parte =~ /digo \.+:\s+(\d+)</) {
        $codigo = $1;
      } else {
        $codigo = '';
      }
      
      my $op = {codigo => $codigo,
        cidade => $cidade,
        estado => $estado,
        titulo => $titulo,
        data => $data,
        empresa => $empresa,
        email => $email,
        descricao => $descricao};
      
      push @{$retorno->{op}}, $op;
    }
  }

  return $retorno;
}

1;
