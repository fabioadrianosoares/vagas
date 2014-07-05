'use strict';

angular.module('VagasApp.controllers', ['ngSanitize']).
  controller('PesquisarCtrl', ['$scope', '$location', 'Vagas', pesquisar])
  .controller('ResultadoCtrl', ['$scope', '$location', '$routeParams', 'Vagas', resultado]);

function pesquisar($scope, $location, Vagas) {
  $scope.mensagemErro = '';
  var init = function () {
    $scope.filtro = '';
    Vagas.inicio().error(function () {
      $scope.mensagemErro = Vagas.erro;
    });
  };

  $scope.pesquisar = function () {
    $scope.mensagemErro = '';
    Vagas.pesquisar($scope.filtro, $scope.verificacao).
    success(function () {
      if (Vagas.tv == 0) {
        $scope.mensagemErro = 'Nenhuma vaga encontrada';
      } else {
        $location.path('/resultado/' + Vagas.lista[0].codigo);
      }
    });
  }

  init();
}

function resultado($scope, $location, $routeParams, Vagas) {
  $scope.tv = Vagas.tv;
  $scope.vaga = {codigo: '', data: '', titulo: '', cidade: '', empresa: '', email: ''};
  $scope.codigoAnterior = '';
  $scope.codigoProximo = '';
  $scope.mensagemErro = '';
  if (Vagas.tv == 0) {
    // verificar cache para link permanente
    Vagas.cache($routeParams.vagaId).
    success(function () {
      // exibir o registro
      resultado($scope, $location, $routeParams, Vagas);
    }).error(function () {
      // falhou
      $scope.mensagemErro = Vagas.erro;
    });
    return;
  }

  var encontrou = false;

  for (var i = 0; i < Vagas.lista.length; i++) {
    if (Vagas.lista[i].codigo == $routeParams.vagaId) {
      encontrou = true;
      $scope.posicao = i + 1;
      $scope.vaga = Vagas.lista[i];
      if (i < Vagas.lista.length - 1) {
        $scope.codigoProximo = Vagas.lista[i + 1].codigo;
      }
      break;
    } else {
      $scope.codigoAnterior = Vagas.lista[i].codigo;
    }
  }

  if (!encontrou) {
    Vagas.erro = 'Código não encontrado: ' + $routeParams.vagaId;
    $location.path('/');
  }

  // buscar mais registros
  if ($scope.codigoProximo == '' && Vagas.lista.length < Vagas.tv) {
    Vagas.mais().success(function () {
      $scope.codigoProximo = Vagas.lista[$scope.posicao].codigo;
    });
  };

  $scope.vagas = Vagas.lista;
  $scope.carregado = $scope.vagas.length;
  $scope.codigo = $routeParams.vagaId;

  $scope.proximo = function () {
    $location.path('/resultado/' + $scope.codigoProximo);
  };

  $scope.anterior = function () {
    $location.path('/resultado/' + $scope.codigoAnterior);
  };  
}