module Moonshado
  class Configuration

    OPTIONS = [:api_key, :keywords, :sms_uri, 
               :keyword_uri, :auto_register_keyword,
               :host, :http_open_timeout, :http_read_timeout,
               :port, :protocol, :secure,
               :production_environment].freeze

    attr_accessor :api_key
    attr_accessor :keywords
    attr_accessor :sms_uri
    attr_accessor :keywords_uri
    attr_accessor :secure
    attr_accessor :http_open_timeout
    attr_accessor :http_read_timeout
    attr_accessor :host
    attr_accessor :auto_register_keywords
    attr_accessor :production_environment
    attr_accessor :port
    attr_accessor :message_length_range
    attr_accessor :message_length_check

    alias_method :secure?, :secure
    alias_method :message_length_check?, :message_length_check

    def initialize
      @secure                   = false
      @host                     = 'heroku.moonshado.com'
      @http_open_timeout        = 10
      @http_read_timeout        = 10
      @production_environment   = true
      @sms_uri                  = '/sms'
      @keywords_uri             = '/keywords'
      @auto_register_keywords   = false
      @port                     = default_port
      @message_length_range     = 3..115
      @message_length_check     = true
    end

    def api_key
      formatted_api_key if @production_environment
    end

    def formatted_api_key
      url_obj = URI.parse(@api_key)

      if (url_obj.class == URI::Generic)
        @api_key
      else
        url_obj.user
      end
    end

    def [](option)
      send(option)
    end

    def to_hash
      OPTIONS.inject({}) do |hash, option|
        hash.merge(option.to_sym => send(option))
      end
    end

    def merge(hash)
      to_hash.merge(hash)
    end

    def port
      @port || default_port
    end

    def protocol
      if secure?
        'https'
      else
        'http'
      end
    end

    def credit_uri
      "#{sms_uri}/credit"
    end

    private
      def default_port
        if secure?
          443
        else
          80
        end
      end
  end
end
