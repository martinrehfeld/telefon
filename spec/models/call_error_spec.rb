require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CallError do

  before(:each) do
    @call_error = CallError.new
  end

  it "should respond to on" do
    @call_error.should respond_to(:on)
  end
  
  it "should add a message to a specified field" do
    @call_error.add(:my_field, "errormessage")
    @call_error.on(:my_field).should == "errormessage"
  end
  
  it "should add a messga to the base object" do
    @call_error.add_to_base("errormessage")
    @call_error.on_base.should == "errormessage"
  end
  
  it "should provide full error messages on base and individual fields" do
    @call_error.add(:my_field, "errormessage")
    @call_error.add_to_base("errormessage")
    @call_error.full_messages == [
      "errormessage",
      "My Field errormessage"
    ]
  end

end
