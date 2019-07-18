# frozen_string_literal: true

module DeepLinksHelper
  def render_html(links)
    html = ['<ul>']
    links.split("\n").each do |link|
      html << "<li><a href=\"#{link}\">#{link}</a></li>"
    end
    html << '</ul>'

    raw html.join("\n")
  end
end
