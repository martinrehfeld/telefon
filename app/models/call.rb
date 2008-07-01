class Call
  attr_accessor :origin, :destination
  
  def new_record?
    true
  end
  
  def origins
    response = Sipgate.instance.own_uri_list
    return nil unless response[:status_code] == 200 && response[:own_uri_list]
    response[:own_uri_list].select{|uri_spec| uri_spec[:tos] == ["voice"]}.collect{|uri_spec| [uri_spec[:uri_alias].blank? ? uri_spec[:e164_out] : uri_spec[:uri_alias], uri_spec[:sip_uri]]}
  end

  def initialize(attrs = {})
    attrs.each do |k,v|
      instance_variable_set "@#{k}".to_sym, to_sip_uri(v)
    end
  end

private

  def to_sip_uri(phone_number_spec)
    return phone_number_spec if phone_number_spec =~ /[0-9]+@sipgate\.(de|net)/
    phone_number_spec.nil? ? nil : "sip:#{phone_number_spec}@sipgate.net"
  end
end
