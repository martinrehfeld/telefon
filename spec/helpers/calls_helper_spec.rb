require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsHelper do
  
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(CallsHelper)
  end
  
  describe "phone_number" do
    it "should convert a SIP URI into a phone number wrapped by a span" do
      helper.phone_number("sip:49304711@sipgate.net").should ==
        '<span class="phone-number">+49 304711</span>'
    end
    
    it "should strip off leading 2200 or 1100 from the phone number (seem to be used by Sipgate internally)" do
      helper.phone_number("sip:220049304711@sipgate.net").should ==
        '<span class="phone-number">+49 304711</span>'
        helper.phone_number("sip:110049304711@sipgate.net").should ==
          '<span class="phone-number">+49 304711</span>'
    end
  end
  
  describe "phone_status" do
    it "should convert a call status to an image and text representation" do
      %w(outgoing accepted missed).each do |status|
        helper.phone_status(status).should =~
          /<span class="call-status"><img alt="#{status.titleize}" src="\/images\/#{status}.gif.+" \/>&nbsp;#{status}<\/span>/
      end
    end
  end
end
