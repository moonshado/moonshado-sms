require 'helper'

class Moonshado::SmsTest < Test::Unit::TestCase
  context Moonshado::Sms do
    setup do
      Moonshado::Sms.configure do |config|
        config.api_key = '20lsdjf2'
        config.production_environment = false
      end
    end

    should "format number with dashs" do
      sms = Moonshado::Sms.new("1-555-5556471", "test")
      assert_equal(sms.format_number("1-555-5556471"), "15555556471")
    end

    should "format number with brackets" do
      sms = Moonshado::Sms.new("1(555)5556471", "test")
      assert_equal(sms.format_number("1-555-5556471"), "15555556471")
    end

    should "format number with brackets and dashs" do
      sms = Moonshado::Sms.new("1(555)555-6471", "test")
      assert_equal(sms.format_number("1-555-5556471"), "15555556471")
    end

    should "format number with no country code" do
      sms = Moonshado::Sms.new("(555)555-6471", "test")
      assert_raise(Moonshado::Sms::MoonshadoSMSException) do
        sms.format_number("5555556471")
      end
    end

    should "raise on invalidate message lenght" do
      sms = Moonshado::Sms.new("1(555)555-6471", "Well, if you like burgers give 'em a try sometime. I can't usually get 'em myself because my girlfriend's a vegitarian which pretty much makes me a vegitarian. But I do love the taste of a good burger. Mm-mm-mm. You know what they call a Quarter Pounder with cheese in France?")

      assert_raise(Moonshado::Sms::MoonshadoSMSException) do
        sms.deliver_sms
      end
    end

    should "not production submit sms" do
      sms = Moonshado::Sms.new("1(555)555-6471", "test")

      assert_equal(sms.deliver_sms, {"id"=>"sms_id_mock", "stat"=>"ok"})
    end
  end
end