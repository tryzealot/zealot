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

  def iOS?
    request.user_agent =~ /iPhone|iPad/i
  end

  def android?
    request.user_agent =~ /Android/i
  end

  def iPhone?
    request.user_agent =~ /iPhone/i
  end

  def iPad?
    request.user_agent =~ /iPad/i
  end

  def detect_device
    device = if iPhone?
      "iPhone"
    elsif iPad?
      "iPad"
    elsif android?
      "Android"
    else
      "Other"
    end
  end
end
