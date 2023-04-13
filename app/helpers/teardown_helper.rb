# frozen_string_literal: true

module TeardownHelper
  def android_v1_signature?(certificates)
    !certificates.any? { |cert| cert.key?('scheme') }
  end

  def certificate_name(dn)
    dn.map { |k, v| "#{k}=#{v}" }.join(', ')
  end

  def expired_date_tips(expired_date, colorful: true, prefix: nil)
    time = Time.parse(expired_date)
    duration = ActiveSupport::Duration.build(time - Time.now)
    time_in_words = distance_of_time_in_words(time, Time.now)

    style_name = 'text-green'
    message = t('teardowns.show.expired_in', time: time_in_words)

    if duration.value < 0
      style_name = 'text-red'
      message = t('teardowns.show.already_expired', time: time_in_words)
    elsif duration.value == 0
      style_name = 'text-red'
      message = t('teardowns.show.expired')
    else
      style_name = (duration.value <= 3.months.to_i) ? 'text-yellow' : 'text-green'
    end

    content_tag(:span, "#{prefix}#{message}", class: colorful ? [style_name, 'text-bold'] : [])
  end
end
