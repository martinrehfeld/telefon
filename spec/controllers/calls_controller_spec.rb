require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsController do

  before(:all) do
    # make sure no API calls are actually performed
    mock_server = mock("xmlrpc-server")
    mock_server.should_receive(:call).with(any_args).any_number_of_times.and_return({'StatusCode' => 200})
    @sipgate_server = Sipgate.instance.server
    Sipgate.instance.server = mock_server
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
    Sipgate.instance.server = @sipgate_server
  end
end
