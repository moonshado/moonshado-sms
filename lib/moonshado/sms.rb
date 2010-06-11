module Moonshado
  class Sms
    attr_accessor :number, :message

    class << self
      attr_accessor :configuration
      attr_accessor :sender

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
        self.sender = Sender.new(configuration)
        if configuration.auto_register_keywords
          Moonshado::Sms::Keywords.register_keywords
        end
      end

      def find(id)
        response = sender.get(configuration.sms_uri + "/#{id}")

        Yajl::Parser.new.parse(response.body)
      end
    end

    def initialize(number = "", message = "")
      @number = number
      @message = message
    end

    # def self.find(id)
    #   if config[:test_env] == true
    #     {:sms => {:id => id, :reports => '[{"update_date":"2010-01-03T22:56:45-08:00","status_info":"test"}]'}, :stat => "ok"}
    #   else
    #     response = RestClient.get("#{url}/#{id}")
    #     JSON.parse(response.body)
    #   end
    # end

    def deliver_sms
      raise MoonshadoSMSException.new("Invalid message") unless is_message_valid?(@message)

      data = {:sms => {:device_address => format_number(@number), :message => @message}}

      if production_environment?
        response = sender.send_to_moonshado(data, configuration.sms_uri)
      else
        response = RestClient::Response.create('{"stat":"ok","id":"sms_id_mock"}', "", {})
      end

      parse(response.to_s)
    rescue MoonshadoSMSException => exception
      raise exception
    end

    def format_number(number)
      formatted = number.scan(/\d+/i).join
      return is_number_valid?(formatted) ? formatted : (raise MoonshadoSMSException.new("Phone number (#{number}) is not formatted correctly"))
    end

    def is_number_valid?(number)
      number.length >= 11 && number[/^.\d+$/]
    end

    def is_message_valid?(message)
      message.size <= 115 && !message.nil? && message.is_a?(String) && !message.empty?
    end

    class MoonshadoSMSException < StandardError; end

    private
      def sender
        Moonshado::Sms.sender
      end

      def configuration
        Moonshado::Sms.configuration
      end

      def production_environment?
        configuration.production_environment
      end

      def parse(json)
        parser = Yajl::Parser.new.parse(json)
      end
  end
end