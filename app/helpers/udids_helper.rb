# frozen_string_literal: true

module UdidsHelper
  def install_qrcode_image_tag
    if Setting.site_appearance != 'auto'
      return image_tag qrcode_udid_index_path(size: :extra, theme: Setting.site_appearance)
    end

    content_tag(:picture) do
      content_tag(:source, media: "(prefers-color-scheme: dark)", srcset: qrcode_udid_index_path(size: :extra, theme: :dark)) do
        image_tag qrcode_udid_index_path(size: :extra)
      end
    end
  end
end
