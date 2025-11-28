# frozen_string_literal: true

require 'omniauth'
require 'securerandom'
require 'digest'

module OmniAuth
  module Strategies
    class MagicLink
      include OmniAuth::Strategy

      option :name, 'magic_link'
      option :token_ttl, 15.minutes
      option :redirect_after_request, '/users/sign_in?sent=1'

      # GET/POST /users/auth/magic_link
      def request_phase
        email = request.params['email']&.to_s&.strip

        if email.present?
          if (user = ::User.find_by(email:))
            if mailer_ready?
              token = user.issue_magic_link_token!(ttl: options.token_ttl)
              ::MagicLinkMailer.sign_in(user:, token:, origin: request.params['origin']).deliver_later
            else
              warn_mailer_not_configured
            end
          end
          # 不暴露邮箱是否存在
          return redirect(options.redirect_after_request)
        end

        Rack::Response.new(render_email_form, 200, 'Content-Type' => 'text/html').finish
      rescue StandardError => e
        fail!(:request_error, e)
      end

      # GET /users/auth/magic_link/callback?token=...
      def callback_phase
        raw_token = request.params['token'].to_s
        user = ::User.consume_magic_link_token(raw_token)
        return fail!(:invalid_credentials) unless user

        @user = user
        super
      rescue StandardError => e
        fail!(:callback_error, e)
      end

      uid { @user.id.to_s }
      info { { email: @user.email } }

      private

      def mailer_ready?
        method = ActionMailer::Base.delivery_method
        return true unless method == :smtp

        settings = ActionMailer::Base.smtp_settings || {}
        settings[:address].present? && settings[:port].present?
      rescue StandardError
        false
      end

      def warn_mailer_not_configured
        Rails.logger.warn('[MagicLink] Action Mailer SMTP not configured (missing address/port). Skipping email delivery.')
      end

      def render_email_form
        <<~HTML
          <!doctype html>
          <html>
            <head><meta charset="utf-8"><title>Magic Link</title></head>
            <body>
              <form method="post" action="#{OmniAuth.config.path_prefix}/#{name}">
                <label>Email</label>
                <input type="email" name="email" required autofocus />
                <button type="submit">Send Magic Link</button>
              </form>
            </body>
          </html>
        HTML
      end
    end
  end
end
