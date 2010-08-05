require 'helper'

class Moonshado::SmsTest < Test::Unit::TestCase
  context Moonshado::Configuration do
    setup do
      Moonshado::Sms.configure do |config|
        config.api_key = 'http://20lsdjf2@localhost:3000/sms'
        config.keywords = {"test" => "http://test.com"}
      end
    end

    should "parse api key" do
      assert_equal(Moonshado::Sms.configuration.api_key, "20lsdjf2")
    end

    should "hold keywords hash" do
      assert_equal(Moonshado::Sms.configuration.keywords, {"test" => "http://test.com"})
    end

    should "return proper api key" do
      Moonshado::Sms.configuration.api_key = "lasjdflk283"

      assert_equal(Moonshado::Sms.configuration.api_key, "lasjdflk283")
    end
  end
end
