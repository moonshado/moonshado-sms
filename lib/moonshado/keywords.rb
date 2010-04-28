require 'active_support'
require 'rest_client'
require 'json'

module Moonshado
  class Keywords
    def self.config
      Moonshado::Sms.config
    end

    def self.url
      @url ||= URI.parse(Moonshado::Sms.config[:sms_api_url])
      "#{@url.scheme}://#{@url.user}:#{@url.password}@#{@url.host}:#{@url.port}/keywords"
    end

    def self.list
      response = RestClient.get(url)

      JSON.parse(response.body)
    end

    def self.register_keywords
      begin
        unless Moonshado::Sms.config[:keywords].nil?
          response = RestClient.post(url, {:keywords => Moonshado::Sms.config[:keywords]})
          JSON.parse(response.body)
        end
      rescue Exception => e
        puts "** Moonshado-Sms: error registering keywords"
      end
    end

    def self.destory(keyword)
      response = RestClient.delete("#{url}/#{keyword}")
      JSON.parse(response.body)
    end

  end
end