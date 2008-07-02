require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sipgate do
  before(:each) do
    @mock_server = mock("sipgate-xmlrpc-server")
  end

  it "should create XMLRPC-Server" do
    Sipgate.instance.server.should be_kind_of(XMLRPC::Client)
  end
  
  it "should read account information from config/sipgate.yml" do
    Sipgate.instance.server.user.should_not be_empty
    Sipgate.instance.server.password.should_not be_empty
  end
  
  it "should identify itself successfully " do
    @mock_server.should_receive(:call).with("samurai.ClientIdentify", Sipgate::CLIENT_ID).once.and_return({'StatusCode' => 200})
    Sipgate.instance.server = @mock_server
    Sipgate.instance.identify[:status_code].should == 200
  end
  
  it "should initiate a voice session properly" do
    from, to = 'sip:123Sipgate.instance.de', 'sip:456Sipgate.instance.de'
    @mock_server.should_receive(:call).with("samurai.SessionInitiate", { 'LocalUri' => from, 'RemoteUri' => to, 'TOS' => 'voice', 'Content' => ''}).once.and_return({'StatusCode' => 200})
    Sipgate.instance.server = @mock_server
    Sipgate.instance.voice_call(from, to)[:status_code].should == 200
  end
  
  it "should provide a list of own URIs" do
    @mock_server.should_receive(:call).with("samurai.OwnUriListGet").once.and_return({'StatusCode' => 200, 'OwnUriList' => []})
    Sipgate.instance.server = @mock_server
    Sipgate.instance.own_uri_list[:status_code].should == 200
    Sipgate.instance.own_uri_list[:own_uri_list].should be_kind_of(Array)
  end
  
  after(:each) do
    Sipgate.instance.reset!
  end
end
