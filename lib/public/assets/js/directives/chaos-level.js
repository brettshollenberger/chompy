angular
  .module("chompy")
  .directive("chaosLevel", [function() {
    return {
      templateUrl: "views/directives/chaos-level.html",
      link: function(scope, element, attrs) {
        scope.chaosLevel = 0;

        var body            = $("body"),
            submitButton    = element.find(".submit"),
            enterKeypresses = element.toObservable("keydown").filter(function(e) {
              var code = e.keyCode || e.which;
              return code == 13;
            }),
            submitClicks = Rx.Observable.fromEvent(submitButton, "click");

        Rx
          .Observable
          .merge(
            submitClicks,
            enterKeypresses
          )
          .map(function() {
            return toSocketRequest("PUT", "/chaos", { chaos: scope.chaosLevel });
          })
          .subscribe(function(request) {
            return angular.socket.send(request);
          });
      }
    }
  }]);
