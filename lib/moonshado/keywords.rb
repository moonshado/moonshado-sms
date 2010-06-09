module Moonshado
  class Sms
    class Keywords
      class << self
        def list
          response = sender.get(configuration.keywords_uri)

          parse(response.body)
        end

        def register_keywords
          response = sender.send_to_moonshado({:keywords => configuration.keywords}, configuration.keywords_uri)

          parse(response.body)
        end

        # def self.destory(keyword)
        #   response = RestClient.delete("#{url}/#{keyword}")
        #   parse(response.body)
        # end

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
  end
end
