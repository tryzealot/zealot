# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
# require 'awesome_print'

Rails.application.load_tasks

namespace :test do
  task release: :environment do
    # c = Channel.take
    # r = c.releases.new
    # r.bundle_id = 'ss'
    # r.release_version = '33'
    # r.build_version = '32'
    # r.changelog = "adfadf\nasdfasdf\n"
    # r.save validate:false

    r = Release.take
    r.changelog = [ { message: 'dddd' } ].to_json
    r.save validate: false
  end

  task body: :environment do
    @release = Release.take
    j = eval "{ app_name: @release.app_name }"
    puts j
    # j.each do |item|
    #   case item
    #   when Hash
    #     item
    #   when Array
    #   end
    # end


    # @release = Release.take
    # puts '{"app_name":":app_name:","changelog":":changelog:"}'.gsub(':app_name:', @release.app_name)
    # .gsub(':version:', @release.version.to_s)
    # .gsub(':release_version:', @release.release_version)
    # .gsub(':build_version:', @release.build_version)
    # .gsub(':bundle_id:', @release.bundle_id)
    # .gsub(':size:', @release.size.to_s)
    # .gsub(':changelog:', @release.changelog)
    # .gsub(':device_type', @release.channel.device_type)
    # .gsub(':install_url:', @release.install_url)
  end

  task env: :environment do
    ENV.each do |k, v|
      puts "#{k} = #{v}"
    end
  end

  task smtp: :environment do
    require 'net/smtp'
    begin
      email = ''
      password = ''
      smtp = Net::SMTP.new('mail.example.com', 25)
      smtp.start('no-reply@example.com', email, password, 'plain')
      ap smtp.started?
    rescue Net::SMTPAuthenticationError
      puts 'user or password is wrong'
    end
  end
end



require 'uri'
require 'base64'
require 'json'

def build_query(url, query)
  encode_query = Base64.strict_encode64 JSON.dump query
  uri = URI.parse url
  uri.query = "protego=#{encode_query}" #.map { |k, v| "#{k}=#{v} " }.join('&')
  uri.to_s
end

task :test do
  url = 'niceliving://open/wechat_miniprogram'
  query = {
    username: 'gh_863a2c58e0ca',
    path: 'pages/audioGlasses/index/index'
  }

  puts "#{url}?#{query.map { |k, v| "#{k.to_s.chomp}=#{v.chomp}" }.join('&')}"
  puts build_query(url, query)
end
