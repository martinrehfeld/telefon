module CallsHelper
  def phone_status(status)
    content_tag :span, :class => 'call-status' do
      image_tag("#{status}.gif") + "&nbsp;#{s_("Call|#{status}")}"
    end
  end
end
