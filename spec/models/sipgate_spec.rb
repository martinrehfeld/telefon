require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sipgate do
  before(:each) do
     @sipgate = Sipgate.instance
     @sipgate_server = Sipgate.instance.server
     @mock_server = mock("xmlrpc-server")
  end

  it "should create XMLRPC-Server" do
    @sipgate.server.should be_kind_of(XMLRPC::Client)
  end
  
  it "should read account information from config/sipgate.yml" do
    @sipgate.server.user.should_not be_empty
    @sipgate.server.password.should_not be_empty
  end
  
  it "should identify itself successfully " do
    @sipgate.server = @mock_server
    @mock_server.should_receive(:call).with("samurai.ClientIdentify", Sipgate::CLIENT_ID).once.and_return({'StatusCode' => 200})
    @sipgate.identify[:status_code].should == 200
  end
  
  it "should initiate a voice session properly" do
    from, to = 'sip:123@sipgate.de', 'sip:456@sipgate.de'
    @sipgate.server = @mock_server
    @mock_server.should_receive(:call).with("samurai.SessionInitiate", { 'LocalUri' => from, 'RemoteUri' => to, 'TOS' => 'voice', 'Content' => ''}).once.and_return({'StatusCode' => 200})
    @sipgate.voice_call(from, to)[:status_code].should == 200
  end
  
  it "should provide a list of own URIs" do
    @sipgate.server = @mock_server
    @mock_server.should_receive(:call).with("samurai.OwnUriListGet").once.and_return({'StatusCode' => 200, 'OwnUriList' => []})
    @sipgate.own_uri_list[:status_code].should == 200
    @sipgate.own_uri_list[:own_uri_list].should be_kind_of(Array)
  end
  
  after(:each) do
    Sipgate.instance.server = @sipgate_server
  end
end
