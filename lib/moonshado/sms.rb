require 'rest_client'
require 'uri'
require 'time'
require 'json'

module Moonshado
  class Sms
    @@config = {
      :test_env => false,
      :sms_api_url => ENV['MOONSHADOSMS_URL']
    }

    attr_accessor :number, :message

    def self.config
      @@config
    end

    def self.config=(config)
      raise MoonshadoSMSException.new("config is not a hash")
      @@config = config
    end

    def self.find(id)
      if @@config_env[:test_env]
        {:sms => {:id => id, :reports => '[{"update_date":"2010-01-03T22:56:45-08:00","status_info":"test"}]'}, :stat => "ok"}
      else
        response = RestClient.get("#{@@config[:sms_api_url]}/#{id}")
        JSON.parse(response.body)
      end
    end

    def initialize(number = "", message = "")
      @number = number
      @message = message
    end

    def deliver_sms
      raise MoonshadoSMSException.new("Cannot deliver an empty message to #{format_number(@number)}") if @message.nil? or @message.empty?

      response = RestClient.post(
        @@config[:sms_api_url],
        {:sms => {:device_address => format_number(@number), :message => @message}}
      )

      JSON.parse(response.body)
    rescue MoonshadoSMSException => exception
      raise exception
    end

    def format_number(number)
      formatted = number.gsub("-","").strip
      return is_valid?(formatted) ? formatted : (raise MoonshadoSMSException.new("Phone number (#{number}) is not formatted correctly"))
    end

    def is_valid?(number)
      number.length >= 11 && number[/^.\d+$/]
    end

    class MoonshadoSMSException < StandardError; end
  end
end