# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Download::Releases', type: :request do
  # Not `app`: that name shadows Rack::Test::Methods#app, which `get` needs to
  # dispatch through the real Rails application.
  let(:zealot_app) { App.create!(name: 'Demo App') }
  let(:scheme) { Scheme.create!(app: zealot_app, name: 'Release') }
  let(:channel) do
    Channel.create!(scheme: scheme, name: 'Beta', device_type: 'android', password: 'sekret')
  end
  let(:release) do
    release = channel.releases.build(build_version: '1', bundle_id: 'com.example.app', changelog: [])
    file = Tempfile.new(['demo', '.apk'])
    file.write('fake apk bytes')
    file.rewind
    release.file = file
    release.save!(validate: false)
    release
  end

  describe 'GET /download/releases/:id/:filename' do
    it 'refuses to serve the file without the channel password' do
      get "/download/releases/#{release.id}/#{release.download_filename}"

      expect(response).to redirect_to(channel_release_path(channel, release, back_url: release.download_url))
    end

    it 'serves the file once the channel password cookie is set' do
      cookies[release.send(:cache_key)] = channel.encode_password

      get "/download/releases/#{release.id}/#{release.download_filename}"

      expect(response).to have_http_status(:ok)
    end
  end
end
