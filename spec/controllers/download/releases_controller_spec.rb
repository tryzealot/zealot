# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Download::ReleasesController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:channel) { instance_double(Channel, to_param: 'abc12') }
  let(:release) { instance_double(Release, id: 1, to_param: '1', channel: channel, download_url: '/dl') }

  before do
    allow(Release).to receive(:find).with('1').and_return(release)
  end

  describe 'GET #show' do
    context 'when signed in as guest' do
      let(:guest) { create(:user, :guest) }

      before do
        sign_in guest
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'redirects to the release page' do
        get :show, params: { id: 1 }
        expect(response).to redirect_to(channel_release_path(channel, release))
      end

      it 'sets a no-permission alert' do
        get :show, params: { id: 1 }
        expect(flash[:alert]).to eq(I18n.t('releases.messages.errors.no_permission_to_download'))
      end
    end

    context 'when not signed in' do
      before do
        allow(controller).to receive(:authorize).and_return(true)
        allow(release).to receive(:cookie_password_matched?).and_return(false)
      end

      it 'does not set a no-permission alert' do
        get :show, params: { id: 1 }
        expect(flash[:alert]).to be_nil
      end
    end
  end

  describe 'GET #download' do
    context 'when signed in as guest' do
      let(:guest) { create(:user, :guest) }

      before do
        sign_in guest
        allow(controller).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      end

      it 'redirects to the release page' do
        get :download, params: { id: 1, filename: 'app.ipa' }
        expect(response).to redirect_to(channel_release_path(channel, release))
      end

      it 'sets a no-permission alert' do
        get :download, params: { id: 1, filename: 'app.ipa' }
        expect(flash[:alert]).to eq(I18n.t('releases.messages.errors.no_permission_to_download'))
      end
    end

    context 'when signed in as member' do
      let(:member) { create(:user, :member) }

      before do
        sign_in member
        allow(controller).to receive(:authorize).and_return(true)
        allow(release).to receive(:file).and_return(double(size: 1024, path: '/tmp/app.ipa'))
        allow(release).to receive(:download_filename).and_return('app.ipa')
        allow(channel).to receive(:perform_web_hook)
        allow(File).to receive(:file?).and_return(true)
        allow(File).to receive(:readable?).and_return(true)
      end

      it 'does not set a no-permission alert' do
        get :download, params: { id: 1, filename: 'app.ipa' }
        expect(flash[:alert]).to be_nil
      end
    end
  end
end
