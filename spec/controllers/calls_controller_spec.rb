require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsController do

  before(:each) do
    # make sure no API calls are actually performed
    @mock_server = mock("calls-controller-xmlrpc-server")
    @mock_server.stub!(:call).and_return({'StatusCode' => 200})
    Sipgate.instance.server = @mock_server
  end

  it "should use CallsController" do
    controller.should be_an_instance_of(CallsController)
  end
  
  describe "GET /calls" do
    it "should provide a dial form" do
      get :index
      response.should be_success
      response.should render_template(:index)
    end
  end
  
  describe "POST /calls" do
    it "should issue a phone call" do
      post :create, { :call => {:destination => '1234567'} }
      response.should redirect_to(calls_url)
    end
    
    it "should re-render the action on errros" do
      @mock_server.stub!(:call).and_return({'StatusCode' => 999})
      post :create, { :call => {:destination => '1234567'} }
      assigns[:call].should_not be_valid
      assigns[:call].errors.on_base.should =~ /\(999\)$/
      response.should render_template(:index)
    end
  end
  
  after(:each) do
    Sipgate.instance.reload!
  end

end
