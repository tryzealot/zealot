# frozen_string_literal: true

class WebHookService
  module PayloadBuilder
    ALLOWLISTED_KEYS = %w[
      event
      username
      email
      title
      name
      app_name
      device_type
      release_version
      build_version
      bundle_id
      size
      file_size
      changelog
      release_url
      install_url
      icon_url
      qrcode_url
      uploaded_at
      ci_url
      branch
      source
      release_type
    ].freeze

    class << self
      def build(body, context)
        context_hash = normalize_context(context)
        return default_payload(context_hash) if body.blank?

        interpolate(body, context_hash)
      end

      def interpolate(template, context_hash)
        rendered = template.to_s.dup

        ALLOWLISTED_KEYS.each do |key|
          val = context_hash[key.to_sym] || context_hash[key] || ''
          raw_str = val.to_s
          escaped_for_json = raw_str.to_json[1..-2] || ''

          rendered.gsub!("{{#{key}}}", escaped_for_json)
          rendered.gsub!("@#{key}", escaped_for_json)
        end

        JSON.parse(rendered).to_json
      end

      def mock_context
        ALLOWLISTED_KEYS.each_with_object({}) do |key, h|
          h[key] = "mock_#{key}"
        end
      end

      private

      def normalize_context(context)
        (context || {}).to_h.symbolize_keys
      end

      def default_payload(ctx)
        {
          event: ctx[:event],
          username: ctx[:username],
          email: ctx[:email],
          title: ctx[:title],
          name: ctx[:app_name] || ctx[:name],
          app_name: ctx[:app_name],
          device_type: ctx[:device_type],
          release_version: ctx[:release_version],
          build_version: ctx[:build_version],
          size: ctx[:file_size] || ctx[:size],
          changelog: ctx[:changelog],
          release_url: ctx[:release_url],
          install_url: ctx[:install_url],
          icon_url: ctx[:icon_url],
          qrcode_url: ctx[:qrcode_url],
          uploaded_at: ctx[:uploaded_at],
          ci_url: ctx[:ci_url],
          branch: ctx[:branch],
          source: ctx[:source],
          release_type: ctx[:release_type]
        }.to_json
      end
    end
  end
end
