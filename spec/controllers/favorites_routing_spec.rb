require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FavoritesController do
  describe "route generation" do

    it "should map { :controller => 'favorites', :action => 'index' } to /favorites" do
      route_for(:controller => "favorites", :action => "index").should == "/favorites"
    end
  
    it "should map { :controller => 'favorites', :action => 'new' } to /favorites/new" do
      route_for(:controller => "favorites", :action => "new").should == "/favorites/new"
    end
  
    it "should map { :controller => 'favorites', :action => 'show', :id => 1 } to /favorites/1" do
      route_for(:controller => "favorites", :action => "show", :id => 1).should == "/favorites/1"
    end
  
    it "should map { :controller => 'favorites', :action => 'edit', :id => 1 } to /favorites/1/edit" do
      route_for(:controller => "favorites", :action => "edit", :id => 1).should == "/favorites/1/edit"
    end
  
    it "should map { :controller => 'favorites', :action => 'update', :id => 1} to /favorites/1" do
      route_for(:controller => "favorites", :action => "update", :id => 1).should == "/favorites/1"
    end
  
    it "should map { :controller => 'favorites', :action => 'destroy', :id => 1} to /favorites/1" do
      route_for(:controller => "favorites", :action => "destroy", :id => 1).should == "/favorites/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'favorites', action => 'index' } from GET /favorites" do
      params_from(:get, "/favorites").should == {:controller => "favorites", :action => "index"}
    end
  
    it "should generate params { :controller => 'favorites', action => 'new' } from GET /favorites/new" do
      params_from(:get, "/favorites/new").should == {:controller => "favorites", :action => "new"}
    end
  
    it "should generate params { :controller => 'favorites', action => 'create' } from POST /favorites" do
      params_from(:post, "/favorites").should == {:controller => "favorites", :action => "create"}
    end
  
    it "should generate params { :controller => 'favorites', action => 'show', id => '1' } from GET /favorites/1" do
      params_from(:get, "/favorites/1").should == {:controller => "favorites", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'favorites', action => 'edit', id => '1' } from GET /favorites/1;edit" do
      params_from(:get, "/favorites/1/edit").should == {:controller => "favorites", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'favorites', action => 'update', id => '1' } from PUT /favorites/1" do
      params_from(:put, "/favorites/1").should == {:controller => "favorites", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'favorites', action => 'destroy', id => '1' } from DELETE /favorites/1" do
      params_from(:delete, "/favorites/1").should == {:controller => "favorites", :action => "destroy", :id => "1"}
    end
  end
end
