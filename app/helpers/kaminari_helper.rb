# frozen_string_literal: true

module KaminariHelper
  def get_pagination_link(is_true, linkt_text, url, rel, remote)
    css_class, url = is_true ? ['page-item disabled', 'javascript:void(0)'] : ['page-item', url]
    build_link url, css_class, rel, linkt_text, remote
  end

  def build_link(url, css_class, rel, linkt_text, remote)
    content_tag(:li, class: css_class) do
      concat(link_to(raw(linkt_text), url, rel: rel, remote: remote, class: 'page-link').html_safe)
    end
  end
end
