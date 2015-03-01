angular
  .module("chompy")
  .directive("urlLoader", [function() {
    return {
      templateUrl: "views/directives/url-loader.html",
      link: function(scope, element, attrs) {
        var body            = $("body"),
            submitButton    = element.find(".submit"),
            enterKeypresses = $(window).toObservable("keydown").filter(function(e) {
              var code = e.keyCode || e.which;
              return code == 13;
            }),
            submitClicks = Rx.Observable.fromEvent(submitButton, "click");

        scope.url = "example.com";

        Rx
          .Observable
          .merge(
            submitClicks,
            enterKeypresses
          )
          .startWith("click")
          .map(function() {
            return toSocketRequest("POST", "/web_requests", { url: scope.url });
          })
          .subscribe(function(request) {
            scope.url = "";
            scope.$apply();
            angular.socket.send(request);
          });
      }
    }
  }]);
