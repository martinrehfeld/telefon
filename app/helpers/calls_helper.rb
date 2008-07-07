module CallsHelper
  def phone_number(sip_uri)
    return nil unless sip_uri && sip_uri.match(/^sip:([0-9]+)@/)
    number = $1
    if number.starts_with?("1100") || number.starts_with?("2200")
      number = number[4..-1]
    end
    content_tag :span, number, :class => 'phone-number'
  end
  
  def phone_status(status)
    content_tag :span, :class => 'call-status' do
      image_tag("#{status}.gif") + "&nbsp;#{s_("Call|#{status}")}"
    end
  end
end
