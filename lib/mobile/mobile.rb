class Mobile < Settingslogic
  source "#{Rails.root}/config/mobile.yml"
  namespace Rails.env
end