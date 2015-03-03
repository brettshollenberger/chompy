angular
  .module("chompy")
  .directive("urlLoader", [function() {
    return {
      templateUrl: "views/directives/url-loader.html",
      link: function(scope, element, attrs) {
        var body            = $("body"),
            submitButton    = element.find(".submit"),
            enterKeypresses = element.toObservable("keydown").filter(function(e) {
              var code = e.keyCode || e.which;
              return code == 13;
            }),
            submitClicks = Rx.Observable.fromEvent(submitButton, "click");

        scope.url           = "example.com";
        scope.latestRequest = scope.url;

	waitForSocketConnection(angular.socket, function() {
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
			scope.latestRequest = scope.url;
			scope.url           = "";
			scope.$apply();
			return angular.socket.send(request);
			});
	});
      }
    }
  }]);
