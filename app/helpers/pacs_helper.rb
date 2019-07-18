# frozen_string_literal: true

module PacsHelper
  def pac_file_url(pac)
    link_to pac_url(pac, format: :pac), pac_url(pac, format: :pac)
  end
end
