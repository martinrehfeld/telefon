require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Favorite do
  before(:each) do
    @valid_attributes = {
      :name => "favorite name",
      :uri => "extension@sipgate.net"
    }
  end

  it "should create a new instance given valid attributes" do
    Favorite.create!(@valid_attributes)
  end
end
