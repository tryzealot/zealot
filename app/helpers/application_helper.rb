module ApplicationHelper
  def emojify(content)
    h(content).to_str.gsub(/:([\w+-]+):/) do |match|
      if emoji = Emoji.find_by_alias($1)
        %(<img alt="#$1" src="#{asset_path("emoji/#{emoji.image_filename}")}" style="vertical-align:middle" width="20" height="20" />)
      else
        match
      end
    end.html_safe if content.present?
  end

  def user_agent
    request.user_agent
  end

  def ios?(source)
    source =~ /iPhone|iPad/i
    !source.empty?
  end

  def android?(source)
    source =~ /Android/i
    !source.empty?
  end

  def detect_device(device)
    if browser.platform.ios? && ios?(device)
      'iOS'
    elsif browser.platform.android? && android?(device)
      'Android'
    else
      'Other'
    end
  end
end
