require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/favorites/index.html.erb" do
  include FavoritesHelper
  
  before(:each) do
    assigns[:favorites] = [
      stub_model(Favorite,
        :name => "value for name",
        :uri => "value for uri"
      ),
      stub_model(Favorite,
        :name => "value for name",
        :uri => "value for uri"
      )
    ]
  end

  it "should render list of favorites" do
    render "/favorites/index.html.erb"
    response.should have_tag("tr>td", "value for name", 2)
    response.should have_tag("tr>td", "value for uri", 2)
  end
end

