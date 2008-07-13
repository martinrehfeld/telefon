require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sipgate do
  it "should create XMLRPC-Server" do
    Sipgate.instance.server.should be_kind_of(XMLRPC::Client)
  end
  
  it "should read account information from config/sipgate.yml" do
    Sipgate.instance.server.user.should_not be_empty
    Sipgate.instance.server.password.should_not be_empty
  end

  describe "with mocked XMLRPC-Server" do
    before(:each) do
      @mock_server = mock("sipgate-xmlrpc-server")
      Sipgate.instance.server = @mock_server
    end

    it "should identify itself successfully " do
      @mock_server.should_receive(:call).with("samurai.ClientIdentify", Sipgate::CLIENT_ID).once.and_return({'StatusCode' => 200})
      Sipgate.instance.identify[:status_code].should == 200
    end

    it "should initiate a voice session properly" do
      from, to = 'sip:123Sipgate.instance.de', 'sip:456Sipgate.instance.de'
      @mock_server.should_receive(:call).with("samurai.SessionInitiate", { 'LocalUri' => from, 'RemoteUri' => to, 'TOS' => 'voice', 'Content' => ''}).once.and_return({'StatusCode' => 200})
      Sipgate.instance.voice_call(from, to)[:status_code].should == 200
    end

    it "should provide a list of own URIs" do
      @mock_server.should_receive(:call).with("samurai.OwnUriListGet").once.and_return({'StatusCode' => 200, 'OwnUriList' => []})
      Sipgate.instance.own_uri_list[:status_code].should == 200
      Sipgate.instance.own_uri_list[:own_uri_list].should == []
    end

    describe "history" do
      it "should be retrievable without filter options" do
        @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {}).once.and_return({'StatusCode' => 200, 'History' => []})
        response = Sipgate.instance.history
        response[:status_code].should == 200
        response[:history].should == []
      end

      it "should be filterable by individual status" do
        %w(missed accepted outgoing).each do |status|
          @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {'StatusList'=>[status]}).once.and_return({'StatusCode' => 200, 'History' => []})
          response = Sipgate.instance.history(:status => status)
          response[:status_code].should == 200
        end
      end

      it "should be filterable by multiple stati" do
        @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {'StatusList'=>%w(accepted missed)}).once.and_return({'StatusCode' => 200, 'History' => []})
        response = Sipgate.instance.history(:status => %w(accepted missed))
        response[:status_code].should == 200
      end
      
      it "should be filterable by an individual LocalURI" do
        @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {'LocalUriList'=>["sip:4711@sipgate.de"]}).once.and_return({'StatusCode' => 200, 'History' => []})
        response = Sipgate.instance.history(:local_uri => "sip:4711@sipgate.de")
        response[:status_code].should == 200
      end

      it "should be filterable by multiple LocalURIs" do
        @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {'LocalUriList'=>%w(sip:4711@sipgate.de sip:4712@sipgate.de)}).once.and_return({'StatusCode' => 200, 'History' => []})
        response = Sipgate.instance.history(:local_uri => %w(sip:4711@sipgate.de sip:4712@sipgate.de))
        response[:status_code].should == 200
      end

      it "should be filterable by start date" do
        @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {'PeriodStart'=>"2008-07-06T14:36:18+0200"}).once.and_return({'StatusCode' => 200, 'History' => []})
        response = Sipgate.instance.history(:start => DateTime.civil(2008, 7, 6, 14, 36, 18, Rational(2, 24)))
        response[:status_code].should == 200
      end

      it "should be filterable by end date" do
        @mock_server.should_receive(:call).with("samurai.HistoryGetByDate", {'PeriodEnd'=>"2008-07-06T14:36:18+0200"}).once.and_return({'StatusCode' => 200, 'History' => []})
        response = Sipgate.instance.history(:end => DateTime.civil(2008, 7, 6, 14, 36, 18, Rational(2, 24)))
        response[:status_code].should == 200
      end
      
      it "should raise ArgumentError when given unknown filter options" do
        lambda {
          Sipgate.instance.history(:unknown_key => "invalid arg")
        }.should raise_error(ArgumentError)
      end
    end
    
    it "should provide a list of phone book items" do
      @mock_server.should_receive(:call).with("samurai.PhonebookListGet").once.and_return({'StatusCode' => 200, 'PhonebookList' => []})
      response = Sipgate.instance.phonebook_list
      response[:status_code].should == 200
      response[:phonebook_list].should == []
    end
    
    describe "phonebook_entry" do
      it "should provide a single phonebook record" do
        @mock_server.should_receive(:call).with("samurai.PhonebookEntryGet", 'EntryIDList'=> ['1']).once.and_return({'StatusCode' => 200, 'EntryList' => []})
        response = Sipgate.instance.phonebook_entry(1)
        response[:status_code].should == 200
        response[:entry_list].should == []
      end
      
      it "should provide phonebook records for given argument list" do
        @mock_server.should_receive(:call).with("samurai.PhonebookEntryGet", 'EntryIDList'=> ['1','2']).once.and_return({'StatusCode' => 200, 'EntryList' => []})
        response = Sipgate.instance.phonebook_entry(1,2)
        response[:status_code].should == 200
        response[:entry_list].should == []
      end
      
      it "should provide phonebook records for given array of ids" do
        @mock_server.should_receive(:call).with("samurai.PhonebookEntryGet", 'EntryIDList'=> ['1','2']).once.and_return({'StatusCode' => 200, 'EntryList' => []})
        response = Sipgate.instance.phonebook_entry([1,2])
        response[:status_code].should == 200
        response[:entry_list].should == []
      end
    end
    
    describe "phonebook" do
      it "should initially fetch all phonebook entries from the server" do
        @mock_server.should_receive(:call).with("samurai.PhonebookListGet").once.and_return({'StatusCode' => 200, 'PhonebookList' => [{ :entry_id => '1', :entry_hash => 'abc' }]})
        @mock_server.should_receive(:call).with("samurai.PhonebookEntryGet", 'EntryIDList'=> ['1']).once.and_return({'StatusCode' => 200, 'EntryList' => [{ :entry_id => '1', :entry_hash => 'abc' }]})
        Sipgate.instance.phonebook
      end

      it "should not fetch unchanged phonebook entries from the server" do
        @mock_server.should_receive(:call).with("samurai.PhonebookListGet").once.and_return({'StatusCode' => 200, 'PhonebookList' => [{ :entry_id => '1', :entry_hash => 'abc' }]})
        @mock_server.should_not_receive(:call).with("samurai.PhonebookEntryGet", anything)
        Sipgate.instance.instance_eval { @phonebook = { '1' => { :entry_id => '1', :entry_hash => 'abc' } } }
        Sipgate.instance.phonebook
      end

      it "should re-fetch changed phonebook entries from the server" do
        @mock_server.should_receive(:call).with("samurai.PhonebookListGet").once.and_return({'StatusCode' => 200, 'PhonebookList' => [{ :entry_id => '1', :entry_hash => 'def' }]})
        @mock_server.should_receive(:call).with("samurai.PhonebookEntryGet", 'EntryIDList'=> ['1']).once.and_return({'StatusCode' => 200, 'EntryList' => [{ :entry_id => '1', :entry_hash => 'def' }]})
        Sipgate.instance.instance_eval { @phonebook = { '1' => { :entry_id => '1', :entry_hash => 'abc' } } }
        Sipgate.instance.phonebook
      end
    end
  
  end
  
  after(:each) do
    Sipgate.instance.reload!
  end
end
