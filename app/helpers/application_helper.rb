module ApplicationHelper
  def javascript(*files, &block)
    if block
      content_for(:head, javascript_include_tag(*files)+"\n"+javascript_tag(capture(&block)))
    else
      content_for(:head, javascript_include_tag(*files))
    end
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
  
  def phone_number(call, attribute)
    sip_uri = call.send attribute
    return nil unless sip_uri && sip_uri.match(/^sip:([0-9]+)@/)

    name = call.send("#{attribute}_name".to_sym) rescue nil
    
    content_tag(:span, Call.normalized_phonenumber(sip_uri), :class => 'phone-number', :style => name.blank? ? nil : 'display:none') +
    content_tag(:span, name, :class => 'phone-name')
  end
end
