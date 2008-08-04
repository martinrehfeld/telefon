require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/favorites/show.html.erb" do
  include FavoritesHelper
  
  before(:each) do
    assigns[:favorite] = @favorite = stub_model(Favorite,
      :name => "value for name",
      :uri => "value for uri"
    )
  end

  it "should render attributes in <p>" do
    render "/favorites/show.html.erb"
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ uri/)
  end
end

