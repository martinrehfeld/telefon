require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/favorites/new.html.erb" do
  include FavoritesHelper
  
  before(:each) do
    assigns[:favorite] = stub_model(Favorite,
      :new_record? => true,
      :name => "value for name",
      :uri => "value for uri"
    )
  end

  it "should render new form" do
    render "/favorites/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", favorites_path) do
      with_tag("input#favorite_name[name=?]", "favorite[name]")
      with_tag("input#favorite_uri[name=?]", "favorite[uri]")
    end
  end
end


