require 'xmlrpc/client'
require 'singleton'

class Sipgate
  
  include Singleton
  
  CLIENT_ID = { 'ClientName' => 'telefon', 'ClientVersion' => "1.0", 'ClientVendor' => 'GL Networks, Berlin'}

  attr_accessor :server
  
  def initialize
    reload!
  end
  
  # reload config from sipgate.yml file and provide corresponding XMLRPC client object
  def reload!
    config = YAML.load_file(File.join(Rails.root,'config','sipgate.yml'))
    @server = XMLRPC::Client.new2("https://#{config['username']}:#{config['password']}@samurai.sipgate.net/RPC2")
    @own_uri_list = nil
  end
  
  # send ClientIdentifiy message
  def identify
    return_hash @server.call("samurai.ClientIdentify", CLIENT_ID)
  end
  
  # use SessionInitiate to connect a voice session
  def voice_call(local_uri, remote_uri)
    return_hash @server.call("samurai.SessionInitiate", {
      'LocalUri'  => local_uri,
      'RemoteUri' => remote_uri,
      'TOS'       => 'voice',
      'Content'   => ''
    })
  end
  
  # use OwnUriListGet to provide a list of own SIP URIs
  def own_uri_list
    if @own_uri_list.nil? || @own_uri_list[:status_code] != 200
      @own_uri_list = return_hash(@server.call("samurai.OwnUriListGet"))
    end

    @own_uri_list
  end
  
  # use HistoryGetByDate to retrieve the session history
  def history(filter_options = {})
    call_options = {}
    call_options['StatusList'] = Array(filter_options.delete(:status)).map(&:to_s) if filter_options[:status]
    call_options['LocalUriList'] = Array(filter_options.delete(:local_uri)).map(&:to_s) if filter_options[:local_uri]
    call_options['PeriodStart'] = filter_options.delete(:start).to_s(:rfc3339) if filter_options[:start]
    call_options['PeriodEnd'] = filter_options.delete(:end).to_s(:rfc3339) if filter_options[:end]
    raise ArgumentError, "Invalid filter option(s): #{filter_options.inspect}" unless filter_options.empty?

    return_hash(@server.call("samurai.HistoryGetByDate", call_options))
  end
  
private
  
  # make server responses look more Ruby like (underscored Symbol as Hash keys)
  def return_hash(h)
    returning new_hash = {} do
      h.each do |k,v|
        new_val = if v.is_a?(Hash)
          return_hash(v)
        elsif v.is_a?(Array)
          v.map{|e| e.is_a?(Hash) ? return_hash(e) : e}
        else
          v
        end
        new_hash[k.to_s.underscore.to_sym] = new_val
      end
    end
  end

end
