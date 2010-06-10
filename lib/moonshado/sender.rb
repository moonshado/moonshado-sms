module Moonshado
  class Sender
    attr_reader :host, :port, :secure, :http_open_timeout, :http_read_timeout, :protocol, :api_key

    def initialize(options = {})
      [:protocol, :host, :port, :secure, :http_open_timeout, :http_read_timeout, :api_key].each do |option|
        instance_variable_set("@#{option}", options[option])
      end
    end

    def send_to_moonshado(data, uri)
      http  = RestClient::Resource.new(
                url(uri),
                :user => api_key,
                :timeout => http_read_timeout,
                :open_timeout => http_open_timeout
              )

      response = http.post(data)
    end

    def get(uri)
      http  = RestClient::Resource.new(
                url(uri),
                :user => api_key,
                :timeout => http_read_timeout,
                :open_timeout => http_open_timeout
              )

      response = http.get
    end

    private
      def url(uri = "")
        URI.parse("#{protocol}://#{host}:#{port}").merge(uri).to_s
      end

      def configuration
        Moonshado::Sms.configuration
      end

      def production_environment?
        configuration.production_environment
      end
  end
end