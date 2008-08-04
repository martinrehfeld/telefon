require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FavoritesController do

  def mock_favorite(stubs={})
    stubs = {
      :save => true,
      :update_attributes => true,
      :destroy => true,
      :to_xml => ''
    }.merge(stubs)
    @mock_favorite ||= mock_model(Favorite, stubs)
  end

  describe "responding to GET /favorites" do

    it "should succeed" do
      Favorite.stub!(:find)
      get :index
      response.should be_success
    end

    it "should render the 'index' template" do
      Favorite.stub!(:find)
      get :index
      response.should render_template('index')
    end
  
    it "should find all favorites" do
      Favorite.should_receive(:find).with(:all)
      get :index
    end
  
    it "should assign the found favorites for the view" do
      Favorite.should_receive(:find).and_return([mock_favorite])
      get :index
      assigns[:favorites].should == [mock_favorite]
    end

  end

  describe "responding to GET /favorites.xml" do

    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/xml"
    end
  
    it "should succeed" do
      Favorite.stub!(:find).and_return([])
      get :index
      response.should be_success
    end

    it "should find all favorites" do
      Favorite.should_receive(:find).with(:all).and_return([])
      get :index
    end
  
    it "should render the found favorites as xml" do
      Favorite.should_receive(:find).and_return(favorites = mock("Array of Favorites"))
      favorites.should_receive(:to_xml).and_return("generated XML")
      get :index
      response.body.should == "generated XML"
    end
    
  end

  describe "responding to GET /favorites/1" do

    it "should succeed" do
      Favorite.stub!(:find)
      get :show, :id => "1"
      response.should be_success
    end
  
    it "should render the 'show' template" do
      Favorite.stub!(:find)
      get :show, :id => "1"
      response.should render_template('show')
    end
  
    it "should find the requested favorite" do
      Favorite.should_receive(:find).with("37")
      get :show, :id => "37"
    end
  
    it "should assign the found favorite for the view" do
      Favorite.should_receive(:find).and_return(mock_favorite)
      get :show, :id => "1"
      assigns[:favorite].should equal(mock_favorite)
    end
    
  end

  describe "responding to GET /favorites/1.xml" do

    before(:each) do
      request.env["HTTP_ACCEPT"] = "application/xml"
    end
  
    it "should succeed" do
      Favorite.stub!(:find).and_return(mock_favorite)
      get :show, :id => "1"
      response.should be_success
    end
  
    it "should find the favorite requested" do
      Favorite.should_receive(:find).with("37").and_return(mock_favorite)
      get :show, :id => "37"
    end
  
    it "should render the found favorite as xml" do
      Favorite.should_receive(:find).and_return(mock_favorite)
      mock_favorite.should_receive(:to_xml).and_return("generated XML")
      get :show, :id => "1"
      response.body.should == "generated XML"
    end

  end

  describe "responding to GET /favorites/new" do

    it "should succeed" do
      get :new
      response.should be_success
    end
  
    it "should render the 'new' template" do
      get :new
      response.should render_template('new')
    end
  
    it "should create a new favorite" do
      Favorite.should_receive(:new)
      get :new
    end
  
    it "should assign the new favorite for the view" do
      Favorite.should_receive(:new).and_return(mock_favorite)
      get :new
      assigns[:favorite].should equal(mock_favorite)
    end

  end

  describe "responding to GET /favorites/1/edit" do

    it "should succeed" do
      Favorite.stub!(:find)
      get :edit, :id => "1"
      response.should be_success
    end
  
    it "should render the 'edit' template" do
      Favorite.stub!(:find)
      get :edit, :id => "1"
      response.should render_template('edit')
    end
  
    it "should find the requested favorite" do
      Favorite.should_receive(:find).with("37")
      get :edit, :id => "37"
    end
  
    it "should assign the found Favorite for the view" do
      Favorite.should_receive(:find).and_return(mock_favorite)
      get :edit, :id => "1"
      assigns[:favorite].should equal(mock_favorite)
    end

  end

  describe "responding to POST /favorites" do

    describe "with successful save" do
  
      it "should create a new favorite" do
        Favorite.should_receive(:new).with({'these' => 'params'}).and_return(mock_favorite)
        post :create, :favorite => {:these => 'params'}
      end

      it "should assign the created favorite for the view" do
        Favorite.stub!(:new).and_return(mock_favorite)
        post :create, :favorite => {}
        assigns(:favorite).should equal(mock_favorite)
      end

      it "should redirect to the created favorite" do
        Favorite.stub!(:new).and_return(mock_favorite)
        post :create, :favorite => {}
        response.should redirect_to(favorite_url(mock_favorite))
      end
      
    end
    
    describe "with failed save" do

      it "should create a new favorite" do
        Favorite.should_receive(:new).with({'these' => 'params'}).and_return(mock_favorite(:save => false))
        post :create, :favorite => {:these => 'params'}
      end

      it "should assign the invalid favorite for the view" do
        Favorite.stub!(:new).and_return(mock_favorite(:save => false))
        post :create, :favorite => {}
        assigns(:favorite).should equal(mock_favorite)
      end

      it "should re-render the 'new' template" do
        Favorite.stub!(:new).and_return(mock_favorite(:save => false))
        post :create, :favorite => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT /favorites/1" do

    describe "with successful update" do

      it "should find the requested favorite" do
        Favorite.should_receive(:find).with("37").and_return(mock_favorite)
        put :update, :id => "37"
      end

      it "should update the found favorite" do
        Favorite.stub!(:find).and_return(mock_favorite)
        mock_favorite.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "1", :favorite => {:these => 'params'}
      end

      it "should assign the found favorite for the view" do
        Favorite.stub!(:find).and_return(mock_favorite)
        put :update, :id => "1"
        assigns(:favorite).should equal(mock_favorite)
      end

      it "should redirect to the favorite" do
        Favorite.stub!(:find).and_return(mock_favorite)
        put :update, :id => "1"
        response.should redirect_to(favorite_url(mock_favorite))
      end

    end
    
    describe "with failed update" do

      it "should find the requested favorite" do
        Favorite.should_receive(:find).with("37").and_return(mock_favorite(:update_attributes => false))
        put :update, :id => "37"
      end

      it "should update the found favorite" do
        Favorite.stub!(:find).and_return(mock_favorite)
        mock_favorite.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "1", :favorite => {:these => 'params'}
      end

      it "should assign the found favorite for the view" do
        Favorite.stub!(:find).and_return(mock_favorite(:update_attributes => false))
        put :update, :id => "1"
        assigns(:favorite).should equal(mock_favorite)
      end

      it "should re-render the 'edit' template" do
        Favorite.stub!(:find).and_return(mock_favorite(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE /favorites/1" do

    it "should find the favorite requested" do
      Favorite.should_receive(:find).with("37").and_return(mock_favorite)
      delete :destroy, :id => "37"
    end
  
    it "should call destroy on the found favorite" do
      Favorite.stub!(:find).and_return(mock_favorite)
      mock_favorite.should_receive(:destroy)
      delete :destroy, :id => "1"
    end
  
    it "should redirect to the favorites list" do
      Favorite.stub!(:find).and_return(mock_favorite)
      delete :destroy, :id => "1"
      response.should redirect_to(favorites_url)
    end

  end

end
