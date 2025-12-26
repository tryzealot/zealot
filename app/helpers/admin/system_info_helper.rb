# frozen_string_literal: true

module Admin::SystemInfoHelper
  def progress_color(percent)
    case percent.to_i
    when 0..60
      'd-progress-success'
    when 61..80
      'd-progress-warning'
    else
      'd-progress-error'
    end
  end
end
