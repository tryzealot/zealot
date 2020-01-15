# frozen_string_literal: true

class Setting < Settingslogic
  source "#{Rails.root}/config/zealot.yml"
  namespace Rails.env
end
