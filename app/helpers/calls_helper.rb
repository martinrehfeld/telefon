module CallsHelper
  def phone_number(call, attribute)
    sip_uri = call.send attribute
    return nil unless sip_uri && sip_uri.match(/^sip:([0-9]+)@/)

    name = call.send("#{attribute}_name".to_sym) rescue nil
    
    content_tag(:span, Call.normalized_phonenumber(sip_uri), :class => 'phone-number', :style => name.blank? ? nil : 'display:none') +
    content_tag(:span, name, :class => 'phone-name')
  end
  
  def phone_status(status)
    content_tag :span, :class => 'call-status' do
      image_tag("#{status}.gif") + "&nbsp;#{s_("Call|#{status}")}"
    end
  end
end
