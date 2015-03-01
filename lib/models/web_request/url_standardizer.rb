class WebRequest
  class UrlStandardizer
    class << self
      def standardize(url)
        url = standardize_scheme(url)
      end

      def standardize_scheme(url)
        unless url.match(/\w+\:\/\//)
          url = "http://#{url}" 
        end

        url
      end
    end
  end
end
