package ParseVagas;

use Mojo::Base -strict;
use Mojo::Util qw(trim html_unescape url_unescape);
use utf8;

sub fazer {
  my $html = shift;

  my $retorno = {op => []};
  
  if ($html =~ /name="tv" value="(\d+)"/) {
    $retorno->{tv} = $1;
  } else {
    $retorno->{tv} = '0';
    $retorno->{erro} //= 'Nenhuma vaga encontrada.';
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
  
  my @partes = split /<div class="box-vagas linha pd">/, $html;

  foreach my $parte (@partes) {
    if ($parte =~ /class="info-data"/) {
      # esta com cara de oportunidade :)
      my ($cidade, $estado, $data, $titulo, $descricao, $empresa, $codigo, $chave);
      
      # limpar highlight
      while ($parte =~ /<span class="highlight"><span style="background-color: #FFFF00"><span style="background-color: #FFFF00">[^<]+<\/span><\/span><\/span>/) {
        $parte =~ s/<span class="highlight"><span style="background-color: #FFFF00"><span style="background-color: #FFFF00">([^<]+)<\/span><\/span><\/span>/$1/g;
      }
      while ($parte =~ /<span style="background-color: #FFFF00"><span style="background-color: #FFFF00">[^<]+<\/span><\/span>/) {
        $parte =~ s/<span style="background-color: #FFFF00"><span style="background-color: #FFFF00">([^<]+)<\/span><\/span>/$1/g;
      }
      $parte =~ s/<span class="highlight"><\/span>//g;

      ($cidade, $estado, $data) = ('', '', '');
      if ($parte =~ /<div class="info-data">([^<]+)/s) {
        my $auxi = trim $1;
        if ($auxi =~ /(.+) - (.+) - (.+)/) {
          ($cidade, $estado, $data) = ($1, $2, $3);
        }
      }

      if ($parte =~ /<div class="cargo m-tb">(.+?)<\/div>/s) {
        $titulo = trim $1;
        if ($titulo =~ /<span>(.+)<\/span>/) {
          $titulo = trim $1;
        }
      } else {
        $titulo = '';
      }
      
      if ($parte =~ /<p>(.+?)<\/p>/s ) {
        $descricao = trim $1;
      } else {
        $descricao = '';
      }
      $descricao =~ s/<br>/\n/isg;
      $descricao =~ s/</&lt;/g;
      $descricao =~ s/>/&gt;/g;
      $descricao =~ s/\n/<br \/>/sg;
      $descricao =~ s/\r//sg;
      $descricao =~ s/^(<br \/>\s*)+//sg;
      $descricao =~ s/\s*(<br \/>\s*)+$//sg;
        
      if ($parte =~ /<strong>Empresa \.+:<\/strong>\s+([^<]+)</) {
        $empresa = trim $1;
      } else {
        $empresa = '';
      }
      
      if ($parte =~ /enviecv.cfm\?codvaga=(\d+)&([^"]+)/) {
        $codigo = $1;
        $chave = $2;
      } else {
        $codigo = '';
        $chave = '';
      }

      my $op = {codigo => $codigo,
        cidade => $cidade,
        estado => $estado,
        titulo => $titulo,
        data => $data,
        empresa => $empresa,
        chave => $chave,
        descricao => $descricao};
      
      push @{$retorno->{op}}, $op;
    }
  }

  return $retorno;
}

sub email {
  my $html = shift;
  my ($erro, $email) = ('', '');

  if ($html =~ /Email : <strong>([^<]+)/i) {
    $email = trim $1;
  } else {
    if ($html =~ /Caracteres inv/i){
      $erro = 'Verificação incorreta.';
    } else {
      $erro = 'Falha ao buscar e-mail.';
    }
  }

  return {erro => $erro, email => $email};
}
1;
