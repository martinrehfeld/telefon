require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Call do

  before(:all) do
    # make sure no API calls are actually performed
    mock_server = mock("xmlrpc-server")
    mock_server.should_receive(:call).with(any_args).any_number_of_times.and_return({'StatusCode' => 200})
    @sipgate_server = Sipgate.instance.server
    Sipgate.instance.server = mock_server
  end

  before(:each) do
    @call = Call.new
  end
  
  it "should always be a new record" do
    @call.should be_new_record
  end
  
  it "should provide a list of call origins" do
    @call.origins
    # TODO: actually test this
  end
  
  describe "initialize" do
    it "should translate its attributes to valid SIP URIs" do
      c = Call.new(:destination => '49301234567')
      c.destination.should match /sip:[0-9]+@sipgate\.(de|net)/
    end

    it "should accept alread valid SIP URIs" do
      c = Call.new(:destination => 'sip:49301234567@sipgate.de')
      c.destination.should == 'sip:49301234567@sipgate.de'
    end

    it "should accept nil" do
      c = Call.new(:destination => nil)
      c.destination.should be_nil
    end
  end

  after(:all) do
    Sipgate.instance.server = @sipgate_server
  end
end
