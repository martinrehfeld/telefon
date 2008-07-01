require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sipgate do
  it "should provide account information from config/sipgate.yml" do
    Sipgate.username.should_not be_empty
    Sipgate.password.should_not be_empty
  end
end
