class Call
  attr_accessor :origin, :destination
  attr_reader :errors
  
  # make sure the FormHelper will generate a _create_ from for this model
  def new_record?
    true
  end
  
  # provide a unique identifier while suppressing the deprecation warning
  # for the usage of Object#id
  def id
    object_id
  end
  
  # provide list of SIP origins (nested Array suitable for form select)
  def origins
    response = Sipgate.instance.own_uri_list
    return nil unless response[:status_code] == 200 && response[:own_uri_list]
    response[:own_uri_list].
      select{|uri_spec| uri_spec[:tos] == ["voice"] }.
      collect{|uri_spec| [
        uri_spec[:uri_alias].blank? ? uri_spec[:e164_out] : uri_spec[:uri_alias],
        uri_spec[:sip_uri]
      ]}
  end

  # initiate a new voice session for this Call
  def dial
    validate
    if errors.blank?
      Sipgate.instance.voice_call(origin, destination)
    else
      { :status_code => 404, :status_string => 'parameter validation failed' }
    end
  end
  
  def validate
    if destination.nil?
      # given destination has incorrect format
      errors.add(:destination, "hat kein gültiges Telefonnummernformat.")
    end
  end
  
  def initialize(attrs = {})
    attrs.each do |k,v|
      send "#{k}=".to_sym, to_sip_uri(v)
    end
    @errors = CallError.new
  end

private

  # translate phone numbers into appropriate SIP URIs
  def to_sip_uri(phone_number_spec)
    case phone_number_spec
    when /sip:[0-9a-z]+@sipgate\.(de|net)/  # already a SIP URI
      phone_number_spec
    when /^[0-9]+$/
      "sip:#{phone_number_spec}@sipgate.de" # phone number
    else
      nil
    end
  end

end
