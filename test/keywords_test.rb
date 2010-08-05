require 'helper'

class Moonshado::SmsTest < Test::Unit::TestCase
  context Moonshado::Sms::Keywords do
    setup do
      Moonshado::Sms.configure do |config|
        config.api_key = '20lsdjf2'
        config.keywords = {"test" => "http://test.com"}
      end
    end

    should "validate keywords" do
      assert(Moonshado::Sms::Keywords.valid_keywords?)
    end

    should "invalid keywords: nil" do
      Moonshado::Sms.configuration.keywords = nil
      assert_equal(false, Moonshado::Sms::Keywords.valid_keywords?)
    end

    should "invalid keywords: {}" do
      Moonshado::Sms.configuration.keywords = {}
      assert_equal(false, Moonshado::Sms::Keywords.valid_keywords?)
    end

    # should "list keywords" do
    #   WebMock.disable_net_connect!
    #   stub_request(:get, "http://20lsdjf2:@heroku.moonshado.com/keywords").with do |request|
    #     request.body == '{"keywords":"[{\"callback_url\":\"http://test.com",\"keyword\":\"test\"}]","stat":"ok"}'
    #   end
    # 
    #   assert_equal(Moonshado::Sms::Keywords.list, Yajl::Parser.new.parse('{"keywords":"[{\"callback_url\":\"http://test.com",\"keyword\":\"test\"}]","stat":"ok"}'))
    # end
  end
end