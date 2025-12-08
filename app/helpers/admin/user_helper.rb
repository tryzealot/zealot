# frozen_string_literal: true

module Admin::UserHelper
  def user_status(user)
    if user.access_locked?
      ['error', t('admin.users.index.locked')]
    elsif user.confirmed_at
      ['success', t('admin.users.index.activated')]
    else
      ['ghost', t('admin.users.index.inactive')]
    end
  end
end
