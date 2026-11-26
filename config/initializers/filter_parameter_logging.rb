# frozen_string_literal: true

Rails.application.config.filter_parameters += %i[
  passw email secret token _key crypt salt certificate otp ssn cvv cvc
  license gem bundle gateway dsn
]
