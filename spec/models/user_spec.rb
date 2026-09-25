# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'guest role' do
    subject(:user) { build(:user, :guest) }

    it { is_expected.to be_guest }
    it { is_expected.not_to be_member }
    it { is_expected.not_to be_developer }
    it { is_expected.not_to be_admin }

    it 'cannot manage' do
      expect(user.manage?).to be false
    end

    it 'returns guest role name' do
      expect(user.role_name).to eq(Setting.builtin_roles[:guest])
    end
  end

  describe '#grant_guest!' do
    let(:user) { create(:user, :member) }

    it 'changes role to guest' do
      user.grant_guest!
      expect(user.reload).to be_guest
    end
  end

  describe '#revoke_guest!' do
    let(:user) { create(:user, :guest) }

    it 'changes role back to member' do
      user.revoke_guest!
      expect(user.reload).to be_member
    end
  end

  describe 'default role on registration' do
    context 'when preset_role is guest' do
      before { allow(Setting).to receive(:preset_role).and_return('guest') }

      it 'assigns guest role to new users' do
        expect(build(:user)).to be_guest
      end
    end

    context 'when preset_role is member' do
      before { allow(Setting).to receive(:preset_role).and_return('member') }

      it 'assigns member role to new users' do
        expect(build(:user)).to be_member
      end
    end
  end
end
