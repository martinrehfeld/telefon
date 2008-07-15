require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallsController do
  describe "route generation" do

    # we expect calls to be the root route
    it "should map { :controller => 'calls', :action => 'index' } to /" do
      route_for(:controller => "calls", :action => "index").should == "/"
    end
  
    it "should map { :controller => 'calls', :action => 'create' } to /" do
      route_for(:controller => "calls", :action => "create").should == "/"
    end

    it "should map { :controller => 'calls', :action => 'history' } to /call-history" do
      route_for(:controller => "calls", :action => "history").should == "/call-history"
    end

  end

  describe "route recognition" do

    # we expect calls to be the root route
    it "should generate params { :controller => 'calls', action => 'index' } from GET /" do
      params_from(:get, "/").should == {:controller => "calls", :action => "index"}
    end

    it "should generate params { :controller => 'calls', action => 'create' } from POST /" do
      params_from(:post, "/").should == {:controller => "calls", :action => "create"}
    end

    it "should generate params { :controller => 'calls', action => 'history' } from GET /call-history" do
      params_from(:get, "/call-history").should == {:controller => "calls", :action => "history"}
    end

  end
end
