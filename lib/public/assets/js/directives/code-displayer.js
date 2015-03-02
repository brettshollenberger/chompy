angular
  .module("chompy")
  .directive("codeDisplayer", [function() {
    return {
      templateUrl: "views/directives/code-displayer.html",
      link: function(scope, element, attrs) {
        var $code        = element.find("code"),
            $highlightEl = $("<code class='language-markup'></code>"),
            entityMap    = {
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
            $code = element.find("code");

            if (response.position == "first") {
              $code.html("");
              $highlightEl = $("<code class='language-markup'></code>");
              $unhighlightedEl = $("<code class='language-markup'></code>");
            }

            $unhighlightedEl.append(response.response);
            $highlightEl.append(response.response);

            if (response.position == "last") {
              if (response.params.url == "example.com") {
                Prism.highlightAll();
              }

              $code.replaceWith($unhighlightedEl);

              if (response.total <= 250) {
                Prism.highlightElement($highlightEl[0], true, function() {
                  $unhighlightedEl.replaceWith($highlightEl);
                });
              }
            }
          });
      }
    }
  }]);
