class Sipgate
  
  @config = YAML.load_file(File.join(Rails.root,'config','sipgate.yml'))
  @username = @config['username']
  @password = @config['password']
  
  def self.username
    @username
  end
  
  def self.password
    @password
  end
  
end
