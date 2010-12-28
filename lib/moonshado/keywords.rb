module Moonshado
  class Sms
    class Keywords
      class << self
        def list
          response = sender.get(configuration.keywords_uri)

          parse(response.body)
        end

        def register_keywords
          raise MoonshadoSMSException.new("no keywords specified") unless valid_keywords?
          response = sender.send_to_moonshado({:keywords => configuration.keywords}, configuration.keywords_uri)

          parse(response.body)
        end

        # def self.destory(keyword)
        #   response = RestClient.delete("#{url}/#{keyword}")
        #   parse(response.body)
        # end

        def valid_keywords?
          configuration.keywords.is_a?(Hash) && (!configuration.keywords.empty?)
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
            JSON.parse(json)
          end
      end
    end
  end
end
