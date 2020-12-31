# frozen_string_literal: true

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[password password_confirmation]
