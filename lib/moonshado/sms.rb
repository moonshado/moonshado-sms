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
          begin
            Moonshado::Sms::Keywords.register_keywords
          rescue Exception => e
            puts "Failed to auto register keywords: #{e.message}"
          end
        end
      end

      def find(id)
        response = sender.get(configuration.sms_uri + "/#{id}")

        JSON.parse(response.to_s)
      end
    end

    def initialize(number = "", message = "")
      @number = number
      @message = message
    end

    def deliver_sms
      raise MoonshadoSMSException.new("Invalid message") unless is_message_valid?(@message)

      data = {:sms => {:device_address => format_number(@number), :message => @message.to_s}}

      if production_environment?
        begin
          response = sender.send_to_moonshado(data, configuration.sms_uri)
        rescue Exception => e
          response = RestClient::Response.create("{\"stat\":\"fail\",\"error\":\"#{e.message}\"}", "", {})
        end
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
      number.length >= 10 && number[/^.\d+$/]
    end

    def is_message_valid?(message)
      if message_length_check?
        message_length_range.include?(message.to_s.size)
      else
        true
      end
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
        begin
          JSON.parse(json)
        rescue Exception => e
          {"stat"=>"fail", "error"=>"json parser error", "response"=>json.to_s}
        end
      end

      def message_length_range
        configuration.message_length_range
      end

      def message_length_check?
        configuration.message_length_check?
      end
  end
end
