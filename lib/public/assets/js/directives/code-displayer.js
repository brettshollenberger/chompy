angular
  .module("chompy")
  .directive("codeDisplayer", [function() {
    return {
      templateUrl: "views/directives/code-displayer.html",
      link: function(scope, element, attrs) {
        var $code = element.find("code"),
            entityMap = {
              "&": "&amp;",
              "<": "&lt;",
              ">": "&gt;",
              '"': '&quot;',
              "'": '&#39;',
              "/": '&#x2F;'
            };

        function escapeHtml(string) {
          return String(string).replace(/[&<>"'\/]/g, function (s) {
            return entityMap[s];
            });
        }

        angular
          .socket
          .responses
          .filter(function(response) {
            return response.response != undefined && response.params.url == scope.latestRequest;
          })
          .map(function(response) {
            response.response = escapeHtml(response.response);
            return response;
          })
          .subscribe(function(response) {
            if (response.position == "first") {
              $code.html("");
            }

            $code.append(response.response);

            if (response.position == "last") {
              Prism.highlightAll();
            }
          });
      }
    }
  }]);
