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
            return response.response != undefined;
          })
          .map(function(response) {
            return escapeHtml(response.response);
          })
          .subscribe(function(html) {
            $code.html(html);
            Prism.highlightAll();
          });
      }
    }
  }]);
