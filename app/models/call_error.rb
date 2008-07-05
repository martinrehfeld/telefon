# mimic the behaviour of ActiveRecord::Errors
class CallError

  def on(field)
    @field_errors[field.to_sym]
  end
  
  def add(field, m = 'invalid')
    @field_errors[field.to_sym] = m
  end

  def add_to_base(m)
    @base << m
  end
  
  def full_messages
    returning(@base.dup) do |msg|
      @field_errors.each{|f,e| msg << "#{f.to_s.humanize} #{e}"}
    end
  end

  def size
    [:@field_errors, :@base].inject(0) {|sum,a| sum + (instance_variable_get(a).send :size rescue 0)}
  end
  alias count size
  
  def blank?
    size == 0
  end
  
  def initialize
    @field_errors, @base = {}, []
  end

end

