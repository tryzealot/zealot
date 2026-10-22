# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sidebar navigation', type: :request do
  include Rails.application.routes.url_helpers

  let!(:app_record) { App.create!(name: 'Sidebar App') }
  let!(:scheme) { app_record.schemes.create!(name: 'Release Scheme') }
  let!(:channel) do
    scheme.channels.create!(
      name: 'App Store',
      device_type: :ios,
      download_filename_type: :version_datetime
    )
  end

  before do
    allow(Setting).to receive(:guest_mode).and_return(true)
  end

  def sidebar_text
    Nokogiri::HTML(response.body).at_css('aside ul.d-menu').text.squish
  end

  it 'renders the global navigation on the dashboard' do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(sidebar_text).to include(I18n.t('dashboard.title'))
    expect(sidebar_text).to include(I18n.t('toolbox_section'))
    expect(sidebar_text).to include(I18n.t('apps.sidebar.active'))
    expect(response.body).not_to include('href="/debug_files"')
  end

  it 'nests active and archived under apps' do
    get apps_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(archived_apps_path)
    expect(sidebar_text).to include(I18n.t('apps.sidebar.archived'))
  end

  it 'renders the app context when inside an app' do
    get app_path(app_record)

    expect(response).to have_http_status(:ok)
    expect(sidebar_text).to include(app_record.name)
    expect(sidebar_text).to include(scheme.name)
    expect(sidebar_text).to include(channel.name)
    expect(sidebar_text).to include(I18n.t('debug_files.title'))
    expect(response.body).to include(app_debug_files_path(app_record))
    expect(sidebar_text).not_to include(I18n.t('toolbox_section'))
  end

  it 'keeps the app context on channel pages' do
    get friendly_channel_overview_path(channel)

    expect(response).to have_http_status(:ok)
    expect(sidebar_text).to include(app_record.name)
    expect(sidebar_text).to include(channel.name)
  end

  it 'serves the app scoped debug files list' do
    get app_debug_files_path(app_record)

    expect(response).to have_http_status(:ok)
    expect(sidebar_text).to include(app_record.name)
  end

  it 'marks an archived app and still lists its schemes' do
    app_record.update!(archived: true)

    get app_path(app_record)

    expect(response).to have_http_status(:ok)
    expect(sidebar_text).to include(scheme.name)
    expect(sidebar_text).to include(I18n.t('apps.sidebar.archived'))
    expect(response.body).not_to include(new_app_scheme_path(app_record))
  end

  it 'does not expose the global debug files list' do
    get '/debug_files'

    expect(response).to have_http_status(:not_found)
  end
end
