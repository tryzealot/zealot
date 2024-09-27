# frozen_string_literal: true

class Zealot::SmtpValidator
  def initialize
    if enabled?
      @address = Setting.mailer_options[:address]
      @port = Setting.mailer_options[:port]
      @starttls = Setting.mailer_options[:enable_starttls]
      @username = Setting.mailer_options[:user_name]
      @password = Setting.mailer_options[:password]
    end
  end

  def configured?
    return false unless enabled?

    @address.presence && @port.presence && @port.presence && @password.presence
  end

  def verify
    Net::SMTP.start(@address, @port) do|smtp|
      smtp.enable_starttls if @starttls
      smtp.authenticate(@username, @password, auth_method).success?
    end

    true
  rescue StandardError => e
    @error = e
    false
  end

  def error_message
    case @error
    when Net::SMTPAuthenticationError
      'Username and Password not accepted, check your SMTP username and password.'
    else
      'Unkown error, check your SMTP settings.'
    end
  end

  private

  def enabled?
    !Rails.env.development? ||
    (Rails.env.development? && ActiveModel::Type::Boolean.new.cast(ENV['ENABLE_DEVELOPMENT_MAILER_TEST']))
  end

  def auth_method
    value = Setting.mailer_options[:auth_method].presence || 'plain'
    value == 'none' ? nil : value.to_sym
  end
end
