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
end
