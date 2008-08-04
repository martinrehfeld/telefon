require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/favorites/edit.html.erb" do
  include FavoritesHelper
  
  before(:each) do
    assigns[:favorite] = @favorite = stub_model(Favorite,
      :new_record? => false,
      :name => "value for name",
      :uri => "value for uri"
    )
  end

  it "should render edit form" do
    render "/favorites/edit.html.erb"
    
    response.should have_tag("form[action=#{favorite_path(@favorite)}][method=post]") do
      with_tag('input#favorite_name[name=?]', "favorite[name]")
      with_tag('input#favorite_uri[name=?]', "favorite[uri]")
    end
  end
end


