# frozen_string_literal: true

namespace :zealot do
  namespace :demo do
    DEMO_APP = "Pockage Casts"

    task generate_app: :environment do
      user = User.find_by(role: :admin)

      # Clear dirty data
      App.destroy_by(name: DEMO_APP)

      # Create new app
      app = user.create_app(name: DEMO_APP, owner: true)
      schemes = [
        I18n.t('settings.preset_schemes.enterprise'),
      ]
      channels = %i[Android iOS]

      schemes.each do |scheme_name|
        scheme = app.schemes.find_or_create_by name: scheme_name
        channels.each do |channel_name|
          scheme.channels.find_or_create_by name: channel_name,
                                            device_type: channel_name.downcase.to_sym

        end
      end

      # files = [
      #   {
      #     path: '',
      #     changelog: {}
      #   }
      # ]
    end

    task generate_users: :environment do
      password = '1234567890'     # insecret password, just for test.
      email_domain = 'zealot.com' # fake too
      accounts = {
        admin: 3,
        developer: 5,
        member: 10
      }

      accounts.each do |role, count|
        count.times do
          username = Faker::Internet.username
          email = Faker::Internet.email(name: username, separators: ['-'], domain: email_domain)

          puts "Create role #{role} user: #{email}"
          confirmed_at = role == :member && [true, false].sample ? Time.current : nil
          User.find_or_create_by!(email: email) do |user|
            user.username = username
            user.password = password
            user.password_confirmation = password
            user.role = role.to_sym
            user.confirmed_at = confirmed_at
          end
        end
      end

      puts "Done, all users password is #{password}."
    end
  end
end
