'use strict';

angular.module('VagasApp', [
  'ngRoute',
  'VagasApp.services',
  'VagasApp.controllers'
]).
config(['$routeProvider', function($routeProvider) {
  $routeProvider.when('/pesquisar', {templateUrl: 'partials/pesquisar.html', controller: 'PesquisarCtrl'});
  $routeProvider.when('/resultado/:vagaId', {templateUrl: 'partials/resultado.html', controller: 'ResultadoCtrl'});
  $routeProvider.otherwise({redirectTo: '/pesquisar'});
}]);
