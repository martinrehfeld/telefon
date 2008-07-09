require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Call do

  before(:each) do
    # make sure no API calls are actually performed
    @mock_server = mock("call-xmlrpc-server")
    @mock_server.stub!(:call).and_return({'StatusCode' => 200})
    Sipgate.instance.server = @mock_server
    @call = Call.new
  end
  
  describe "ActiveSupport form helper integration" do
    it "should resond to id" do
      @call.id.should == @call.object_id
    end

    it "should always be a new record" do
      @call.should be_new_record
    end
  end
  
  describe "ActiveRecord::Errors integration" do
    it "should respond to errors" do
      @call.should respond_to(:errors)
      @call.errors.should respond_to(:on)
    end
    
    it "should translate attributes to human readable representation" do
      Call.human_attribute_name(:origin).should == "Origin"
      Call.human_attribute_name(:destination).should == "Destination"
    end
  end
  
  describe "Gettext interface" do
    it "respond to custom_error_messages_d (class and instance)" do
      Call.should respond_to(:custom_error_messages_d)
      Call.custom_error_messages_d.should be_kind_of(Hash)
      @call.should respond_to(:custom_error_messages_d)
      @call.custom_error_messages_d.should be_kind_of(Hash)
    end
    
    it "should respond to gettext" do
      @call.should respond_to(:gettext)
      @call.gettext("SOMESYMBOL").should == "SOMESYMBOL"
    end
  end
  
  it "should provide a list of call origins (only voice services)" do
    @mock_server.stub!(:call).and_return({
      :status_string=>"Method success",
      :status_code=>200,
      :own_uri_list=>[
        {:default_uri=>true, :e164_out=>"4711", :uri_alias=>"First Account", :sip_uri=>"sip:4711@sipgate.de", :tos=>["voice"]},
        {:default_uri=>false, :e164_out=>"4712", :uri_alias=>"", :sip_uri=>"sip:4712@sipgate.de", :tos=>["voice", "fax"]},
        {:default_uri=>false, :e164_out=>"4713", :uri_alias=>"", :sip_uri=>"sip:4713@sipgate.de", :tos=>["fax"]}
      ]
    })
    @call.origins.should == [
      ["First Account", "sip:4711@sipgate.de"],
      ["4712", "sip:4712@sipgate.de"]
    ]
  end
  
  it "should provide a call history (only voice services)" do
    @mock_server.stub!(:call).and_return({
      :status_string=>"Method success",
      :status_code=>200,
      :history=>[
        # outgoing voice
        {:entry_id=>"O_fffffffffffffffffffffffffffffffa", :timestamp=>"2008-07-06T14:36:18+0200", :status=>"outgoing", :remote_uri=>"sip:0815@sipgate.net", :local_uri=>"sip:4711@sipgate.net", :tos=>"voice"},
        # incoming voice
        {:entry_id=>"O_fffffffffffffffffffffffffffffffb", :timestamp=>"2008-07-06T14:36:19+0200", :status=>"accepted", :remote_uri=>"sip:0815@sipgate.net", :local_uri=>"sip:4711@sipgate.net", :tos=>"voice"},
        # incoming fax (ignored)
        {:entry_id=>"O_fffffffffffffffffffffffffffffffc", :timestamp=>"2008-07-06T14:36:20+0200", :status=>"accepted", :remote_uri=>"sip:0815@sipgate.net", :local_uri=>"sip:4712@sipgate.net", :tos=>"fax"}
      ]
    })
    response = Call.history
    response.should have(2).entries
    response.last.origin.should == "sip:0815@sipgate.net"
    response.last.destination.should == "sip:4711@sipgate.net"
    response.first.origin.should == "sip:4711@sipgate.net"
    response.first.destination.should == "sip:0815@sipgate.net"
  end
  
  describe "outbound?" do
    it "should return true if the call status is 'outgoing'" do
      @call.status = 'outgoing'
      @call.outbound?.should be_true
    end

    it "should return false if the call status is 'accepted'" do
      @call.status = 'accepted'
      @call.outbound?.should be_false
    end

    it "should return false if the call status is 'missed'" do
      @call.status = 'missed'
      @call.outbound?.should be_false
    end
  end
  
  describe "initialize" do
    it "should translate its attributes to valid SIP URIs" do
      c = Call.new(:destination => '49301234567')
      c.destination.should == 'sip:49301234567@sipgate.de'
    end

    it "should accept already valid SIP URIs unaltered" do
      c = Call.new(:destination => 'sip:49301234567@sipgate.de')
      c.destination.should == 'sip:49301234567@sipgate.de'
    end

    it "should accept nil" do
      c = Call.new(:destination => nil)
      c.destination.should be_nil
    end
    
    it "should accept formatted telephone numbers" do
      c = Call.new(:destination => '+49 30 1234.567')
      c.destination.should == 'sip:49301234567@sipgate.de'
      c = Call.new(:destination => '(030) 1234-567')
      c.destination.should == 'sip:0301234567@sipgate.de'
    end
    
  end
  
  describe "valdidation" do
    it "should add an error to destination if given an invalid phone number" do
      c = Call.new(:destination => '*123#'); c.validate
      c.errors.on(:destination).should_not be_blank
    end

    it "should add an error to destination if given an invalid SIP URI" do
      c = Call.new(:destination => 'sip:10000'); c.validate
      c.errors.on(:destination).should_not be_blank
    end

    it "should add no error to destination if given an valid phone number" do
      c = Call.new(:destination => '123'); c.validate
      c.errors.on(:destination).should be_blank
    end

    it "should add no error to destination if given an valid SIP URI" do
      c = Call.new(:destination => 'sip:10000@sipgate.net'); c.validate
      c.errors.on(:destination).should be_blank
    end
  end
  
  describe "dial" do
    it "should validate before dialing" do
      c = Call.new(:destination => '*123#')
      response = c.dial
      c.should_not be_valid
      response[:status_code].should == 407
    end
    
    it "should initiate the call if validation passes" do
      c = Call.new(:destination => '123')
      response = c.dial
      c.should be_valid
      response[:status_code].should == 200
    end
  end

  after(:each) do
    Sipgate.instance.reload!
  end
end
