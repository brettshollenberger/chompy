angular
  .module('chompy')
  .directive('notifications', [function() {
    return {
      link: function(scope, element, attr) {
        angular.socket.responses.filter(function(response) {
          return response.error && response.error == "Max attempts exceeded";
        })
        .subscribe(function(response) {
          $.notify({
            title: "<strong>Uh oh:</strong> ",
            message: "We didn't receive any response from " + response.params.url + ". Try again in a bit."
          },{
            type: "danger",
            animate: {
              enter: 'animated fadeInDown',
              exit: 'animated fadeOutUp'
            }
          });
        });

        angular.socket.responses.filter(function(response) {
          return response.error && response.error == "Circuit breaker open";
        })
        .subscribe(function(response) {
          $.notify({
            title: "<strong>Uh oh:</strong> ",
            message: "The backend is currently experiencing difficulties. Please try again later."
          },{
            type: "danger",
            animate: {
              enter: 'animated fadeInDown',
              exit: 'animated fadeOutUp'
            }
          });
        });

        angular.socket.responses.filter(function(response) {
          return response.error && response.error == "Invalid request";
        })
        .subscribe(function(response) {
          $.notify({
            title: "<strong>Uh oh:</strong> ",
            message: response.params.url + " is not a valid URL. Try again."
          },{
            type: "danger",
            animate: {
              enter: 'animated fadeInDown',
              exit: 'animated fadeOutUp'
            }
          });
        });
      }
    }
  }]);
