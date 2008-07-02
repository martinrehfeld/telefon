require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsController do

  before(:all) do
    # make sure no API calls are actually performed
    @mock_server = mock("calls-controller-xmlrpc-server")
    @mock_server.stub!(:call).and_return({'StatusCode' => 200})
    Sipgate.instance.server = @mock_server
  end

  it "should use CallsController" do
    controller.should be_an_instance_of(CallsController)
  end
  
  describe "GET /call/new" do
    it "should provide a dial form" do
      get :new
      response.should be_success
      response.should render_template(:new)
    end
  end
  
  describe "POST /calls" do
    it "should issue a phone call" do
      post :create, { :call => {:destination => '1234567'} }
      response.should redirect_to(new_call_url)
    end
  end
  
  after(:all) do
    Sipgate.instance.reset!
  end

end
