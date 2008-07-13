require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsHelper do
  
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(CallsHelper)
  end
  
  describe "phone_number" do
    before(:each) do
      @call = Call.new(:destination => "sip:49304711@sipgate.de")
    end
    
    it "should convert a SIP URI into a phone number wrapped by a span" do
      helper.phone_number(@call, :destination).should ==
        '<span class="phone-number">49304711</span><span class="phone-name"></span>'
    end
    
    it "should hide the phone number and display the name if Call has <attribute>_name" do
      @call.destination_name = "Somebody"
      helper.phone_number(@call, :destination).should ==
        '<span class="phone-number" style="display:none">49304711</span><span class="phone-name">Somebody</span>'
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
