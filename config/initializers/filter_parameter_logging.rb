# frozen_string_literal: true

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  passw password password_confirmation secret token _key crypt salt certificate otp ssn
]
