require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsController do

  before(:each) do
    # make sure no API calls are actually performed
    @mock_server = mock("calls-controller-xmlrpc-server")
    Sipgate.instance.server = @mock_server
  end

  it "should use CallsController" do
    controller.should be_an_instance_of(CallsController)
  end
  
  describe "GET /calls" do
    it "should provide a dial form" do
      @mock_server.stub!(:call).and_return({'StatusCode' => 200})
      get :index
      response.should be_success
      assigns[:call].should_not be_nil
      assigns[:include_history].should be_true
      response.should render_template(:index)
    end
    
    it "should default origin to value stored in cookie" do
      set_cookie request, :last_call_origin, 'sip:89012345@sipgate.de'
      get :index
      assigns[:call].origin.should == 'sip:89012345@sipgate.de'
    end
  end
  
  describe "POST /calls" do
    it "should issue a phone call" do
      @mock_server.stub!(:call).and_return({'StatusCode' => 200})
      post :create, { :call => {:destination => '1234567'} }
      response.should redirect_to(calls_url)
    end
    
    it "should remember the last used origin in a cookie" do
      @mock_server.stub!(:call).and_return({'StatusCode' => 200})
      post :create, { :call => {:destination => '1234567', :origin => '89012345'} }
      response.should redirect_to(calls_url)
      response.cookies["last_call_origin"].should == ['sip:89012345@sipgate.de']
    end
    
    it "should re-render the action on errros" do
      @mock_server.stub!(:call).and_return({'StatusCode' => 999})
      post :create, { :call => {:destination => '1234567'} }
      assigns[:call].should_not be_valid
      assigns[:call].errors.on_base.should =~ /\(999\)$/
      assigns[:include_history].should be_nil
      response.should render_template(:index)
    end
  end
  
  describe "GET /calls/history" do
    before(:each) do
      @history = []
      @mock_server.stub!(:call).and_return({'StatusCode' => 200, 'History' => @history})
    end
    
    it "should show the Call history (HTML)" do
      get :history
      assigns[:history].should_not be_nil
      response.should render_template(:history)
    end

    it "should show the Call history (AJAX)" do
      controller.expect_render(:partial => 'history')
      xhr :get, :history
      assigns[:history].should == @history
    end
  end
  
  after(:each) do
    Sipgate.instance.reload!
  end

end
