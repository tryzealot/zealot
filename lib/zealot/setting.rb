# frozen_string_literal: true

require 'settingslogic'

class Zealot::Setting < Settingslogic
  source Rails.root.join('config/zealot.yml')
  namespace Rails.env
end
