var scheme = 'ws://',
    uri    = scheme + document.location.host + "/";

angular.socket = new WebSocket(uri);

angular.socket.responses = socketToObservable(angular.socket).map(function(response) {
  return JSON.parse(response);
});

function waitForSocketConnection(socket, callback){
    setTimeout(
        function () {
            if (socket.readyState === 1) {
                if(callback != null){
                    callback();
                }
                return;

            } else {
                waitForSocketConnection(socket, callback);
            }

        }, 5); // wait 5 milisecond for the connection...
}

angular
  .module('chompy', ['ng'])
