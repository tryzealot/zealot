# frozen_string_literal: true

class Setting < Settingslogic
  source Rails.root.join('config/zealot.yml')
  namespace Rails.env
end
