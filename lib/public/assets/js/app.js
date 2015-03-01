var scheme = 'ws://',
    uri    = scheme + document.location.host + "/";

angular.socket = new WebSocket(uri);

angular.socket.responses = socketToObservable(angular.socket).map(function(response) {
  return JSON.parse(response);
});

angular
  .module('chompy', ['ng'])
