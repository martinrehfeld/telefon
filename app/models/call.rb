class Call
  
  SIPGATE_PREFIXES = %w(1100 1200 2200 2001)
  
  attr_accessor :origin, :destination, :origin_name, :destination_name,
                :status, :timestamp

  attr_reader   :errors
  
  include GetText
  bindtextdomain("telefon")

  # add msgids to gettexts .po file
  N_("call")
  N_("Call|missed")
  N_("Call|accepted")
  N_("Call|outgoing")
  N_("Call|Status")
  N_("Call|Timestamp")
  N_("Call|Origin")
  N_("Call|Destination")

  @@custom_error_messages_d = {}
  
  # gettext interface (class method)
  def self.custom_error_messages_d
    @@custom_error_messages_d
  end
  
  # gettext interface (instance method)
  def custom_error_messages_d
    self.class.custom_error_messages_d
  end
  
  # gettext interface (instance method)
  def gettext(str)
    _(str)
  end
  
  # provide human names for attributes (ActiveRecord::Errors interface)
  def self.human_attribute_name(attr)
    s_("#{self}|#{attr.to_s.humanize}")
  end
  
  # make sure the FormHelper will generate a _create_ from for this model
  def new_record?
    true
  end
  
  # provide a unique identifier while suppressing the deprecation warning
  # for the usage of Object#id (form helper interface)
  def id
    object_id
  end
  
  # provide list of SIP origins (nested Array suitable for form select)
  def origins
    response = Sipgate.instance.own_uri_list
    return nil unless response[:status_code] == 200 && response[:own_uri_list]
    response[:own_uri_list].
      select{|uri_spec| uri_spec[:tos].include?("voice") }.
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
      { :status_code => 407, :status_string => 'Invalid parameter value.' }
    end
  end
  
  # provice call history (return array of calls)
  def self.history
    response = Sipgate.instance.history
    return nil unless response[:status_code] == 200 && response[:history]

    phonebook = Sipgate.instance.phonebook(true)

    response[:history].
      select{|entry| entry[:tos].include?("voice") }.
      collect do |entry|
        origin = entry[:local_uri]
        destination = entry[:remote_uri]
        origin, destination = destination, origin unless entry[:status] == 'outgoing'
        origin_name = name_from_phonebook(origin, phonebook)
        destination_name = name_from_phonebook(destination, phonebook)
        Call.new(:origin => origin, :origin_name => origin_name,
                 :destination => destination, :destination_name => destination_name,
                 :timestamp => entry[:timestamp],
                 :status => entry[:status])
      end
  end
  
  def outbound?
    status == 'outgoing'
  end
  
  def validate
    if destination.nil?
      # given destination has incorrect format
      errors.add(:destination, _("has invalid telephone number format."))
    end
  end
  
  def valid?
    errors.empty?
  end
  
  # return the pure numerical form of a given phone number or SIP URI
  def self.normalized_phonenumber(phone)
    phone.to_s.gsub(/(\.|\+|-| |\(|\))/,'').match /[0-9]+/
    number = $&
    number = number[4..-1] if number && SIPGATE_PREFIXES.any?{|prefix| number.starts_with?(prefix)}

    number
  end

  def initialize(attrs = {})
    attrs.each do |k,v|
      translated_val = [:origin, :destination].include?(k.to_sym) ? to_sip_uri(v) : v
      send "#{k}=".to_sym, translated_val
    end
    @errors = ActiveRecord::Errors.new(self)
  end

private

  # translate phone numbers into appropriate SIP URIs
  def to_sip_uri(phone_number_spec)
    case phone_number_spec
    when /sip:[0-9a-z]+@sipgate\.(de|net)/  # already a SIP URI
      phone_number_spec
    when /^[0-9.+\- ()]+$/
      phone_number_spec.gsub!(/(\.|\+|-| |\(|\))/,'')
      "sip:#{phone_number_spec}@sipgate.de" # phone number
    else
      nil
    end
  end
  
  def self.name_from_phonebook(uri, phonebook)
    phonebook.each do |entry_id, phonebook_entry|
      if phonebook_entry[:vcard].telephones.any?{|t| phone_numbers_identical?(t.to_s,uri) }
        return phonebook_entry[:vcard]['FN'] # FN = Full Name
      end
    end
    
    nil # no name found
  end
  
  def self.phone_numbers_identical?(phone1, phone2)
    normalized_phonenumber(phone1) == normalized_phonenumber(phone2)
  end
  
end
