require 'active_support'
require 'rest_client'
require 'json'

module Moonshado
  class Sms
    cattr_accessor :config
    attr_accessor :number, :message

    def self.find(id)
      if config[:test_env] == true
        {:sms => {:id => id, :reports => '[{"update_date":"2010-01-03T22:56:45-08:00","status_info":"test"}]'}, :stat => "ok"}
      else
        response = RestClient.get("#{config[:sms_api_url]}/#{id}")
        JSON.parse(response.body)
      end
    end

    def initialize(number = "", message = "")
      @number = number
      @message = message
    end

    def deliver_sms
      raise MoonshadoSMSException.new("Invalid message") unless is_message_valid?(@message)

      if config[:test_env] == true
        {:stat => 'ok', :id => Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..16]}
      else
        response = RestClient.post(
          config[:sms_api_url],
          {:sms => {:device_address => format_number(@number), :message => @message}}
        )

        JSON.parse(response.body)
      end
    rescue MoonshadoSMSException => exception
      raise exception
    end

    def format_number(number)
      formatted = number.gsub("-","").strip
      return is_number_valid?(formatted) ? formatted : (raise MoonshadoSMSException.new("Phone number (#{number}) is not formatted correctly"))
    end

    def is_number_valid?(number)
      number.length >= 11 && number[/^.\d+$/]
    end

    def is_message_valid?(message)
      message.size <= 115 && !message.nil? && message.is_a?(String) && !message.empty?
    end

    class MoonshadoSMSException < StandardError; end
  end
end