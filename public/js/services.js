'use strict';

angular.module('VagasApp.services', []).
  factory('Vagas', ['$http', function ($http) {
    var servico = {pagina: 1,
      sessao: '',
      lista: [],
      filtro: '',
      verificacao: '',
      erro: '',
      tv: 0};

    servico._preHttp = function () {
      servico._success = undefined;
      servico._error = undefined;
      servico.erro = '';
    }

    servico.success = function (cb) {
      if (cb == undefined) {
        if (servico._success == undefined) {
          servico._success = true;
        } else {
          servico._success();
        }
      } else {
        if (servico._success == undefined) {
          servico._success = cb;
        } else {
          cb();
        }
      }
      return servico;
    };

    servico.error = function (cb) {
      if (cb == undefined) {
        if (servico._error == undefined) {
          servico._error = true;
        } else {
          servico._error();
        }
      } else {
        if (servico._error == undefined) {
          servico._error = cb;
        } else {
          cb();
        }
      }
      return servico;
    };

    servico.inicio = function () {
      servico._preHttp(); // limpar
      servico.pagina = 1;
      $http.get('/inicio').success(function (data) {
        if (data.sessao == undefined) {
          servico.erro = 'Falha ao consultar servidor.';
          servico.error();
        } else {
          servico.sessao = data.sessao;
          servico.success();
        }
      }).error(function (data) {
        servico.erro = 'Falha ao consultar servidor.';
        servico.error();
      });
      return servico;
    };

    servico.pesquisar = function (filtro, verificacao) {
      servico._preHttp(); // limpar
      servico.filtro = filtro;
      servico.verificacao = verificacao;
      servico.tv = 0;
      $http.post('/pesquisar', {filtro: filtro, verificacao: verificacao})
      .success(function (data) {
        servico.tv = data.tv;
        servico.lista = data.op;
        servico.erro = data.erro;
        servico.success();
      }).error(function (data) {
        servico.erro = 'Falha ao consultar servidor.';
        servico.error();
      });
      return servico;      
    };

    servico.mais = function () {
      servico._preHttp(); // limpar
      $http.post('/paginar', {filtro: servico.filtro, tv: servico.tv, pag: ++servico.pagina})
      .success(function (data) {
        for (var i = 0; i < data.op.length; i++) {
          servico.lista.push(data.op[i]);
        };
        if (data.op.length > 0) {
          servico.success();
        }
      }).error(function (data) {
        servico.erro = 'Falha ao consultar servidor.';
        servico.error();
      });      
      return servico; 
    };

    servico.cache = function (vagaId) {
      servico._preHttp(); // limpar
      $http.get('/cache/' + vagaId)
      .success(function (data) {
        servico.tv = data.tv;
        servico.lista = data.op;
        servico.erro = data.erro;
        if (servico.tv == 1) {
          servico.success();
        } else {
          servico.error();
        }
      })
      .error(function () {
        servico.erro = 'Falha ao consultar servidor.';
        servico.error();
      });      
      return servico; 
    };

    return servico;
  }]);
