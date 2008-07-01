require 'xmlrpc/client'
require 'singleton'

class Sipgate
  
  include Singleton
  
  CLIENT_ID = { 'ClientName' => 'telefon', 'ClientVersion' => "1.0", 'ClientVendor' => 'GL Networks, Berlin'}

  attr_accessor :server
  
  def initialize
    config = YAML.load_file(File.join(Rails.root,'config','sipgate.yml'))
    @server = XMLRPC::Client.new2("https://#{config['username']}:#{config['password']}@samurai.sipgate.net/RPC2")
  end
  
  def identify
    return_hash @server.call("samurai.ClientIdentify", CLIENT_ID)
  end
  
  def voice_call(local_uri, remote_uri)
    return_hash @server.call("samurai.SessionInitiate", {
      'LocalUri'  => local_uri,
      'RemoteUri' => remote_uri,
      'TOS'       => 'voice',
      'Content'   => ''
    })
  end
  
private

  def return_hash(h)
    returning({}) do |new_hash|
      h.each {|k,v| new_hash[k.underscore.to_sym] = v }
    end
  end

end
