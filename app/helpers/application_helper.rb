module ApplicationHelper
  def javascript(*files, &block)
    content_for(:head) { javascript_include_tag(*files) }
    content_for(:head, javascript_tag(capture(&block))) if block
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end
end
