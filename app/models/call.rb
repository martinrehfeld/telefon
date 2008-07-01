class Call
  attr_accessor :destination
  
  def new_record?
    true
  end

  def initialize(destination = nil)
    @destination = destination
  end
end
