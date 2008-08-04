class Favorite < ActiveRecord::Base
  
  # alias name to uri_name to support the phone_number helper by implementing
  # a Call like interface
  def uri_name
    name
  end
end
