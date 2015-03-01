angular
  .module('chompy')
  .directive('notifications', [function() {
    return {
      link: function(scope, element, attr) {

        var requestReceived;

        notification({
          title: "Uh oh:",
          type: "danger",
          message: function(response) { 
            return response.params.url + " sent too large a response."
          },
          predicate: function(response) { 
            return response.error && response.error == "Buffer error";
          }
        });

        notification({
          title: "Uh oh:",
          type: "danger",
          message: function(response) { 
            return "We didn't receive any response from " + response.params.url + ". Try again in a bit."
          },
          predicate: function(response) { 
            return response.error && response.error == "Max attempts exceeded";
          }
        });

        notification({
          title: "Uh oh:",
          type: "danger",
          message: function(response) { 
            return "The backend is currently experiencing difficulties. Please try again later."
          },
          predicate: function(response) { 
            return response.error && response.error == "Circuit breaker open";
          }
        });

        notification({
          title: "Uh oh:",
          type: "danger",
          message: function(response) { 
            return response.params.url + " is not a valid URL. Try again."
          },
          predicate: function(response) { 
            return response.error && response.error == "Invalid request";
          }
        });

        notification({
          title: "Uh oh:",
          type: "danger",
          message: function(response) { 
            return "We can't understand the source code of " + response.params.url + "."
          },
          predicate: function(response) { 
            return response.error && response.error == "Uninterpretable response";
          }
        });

        angular
          .socket
          .responses
          .filter(function(response) {
            return response.response != undefined;
          })
          .subscribe(function(response) { 
            clearTimeout(requestReceived);

            setTimeout(function() {
              $.notifyClose();
            }, 800);
          });

        angular
          .socket
          .responses
          .filter(function(response) {
            return response.body == "Request received";
          })
          .subscribe(function(response) { 
            $.notifyClose();

            requestReceived = setTimeout(function() {
              $.notify({
                title: "<strong>Nice: </strong>",
                message: "We got your request for " + response.params.url + "."
              },{
                type: "success",
                animate: {
                enter: 'animated fadeInDown',
                exit: 'animated fadeOutUp'
                }
              });
            }, 800);
          });

        function notification(options) {
          angular
            .socket
            .responses
            .filter(options.predicate)
            .subscribe(function(response) { 
              $.notifyClose();
              clearTimeout(requestReceived);

              $.notify({
                title: "<strong>" + options.title + "</strong>",
                message: options.message(response)
              },{
                type: options.type,
                animate: {
                enter: 'animated fadeInDown',
                exit: 'animated fadeOutUp'
                }
              });
            });
        }
      }
    }
  }]);
