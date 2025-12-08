# frozen_string_literal: true

module UdidsHelper
  def install_qrcode_image_tag
    if current_user&.appearance != 'auto' || Setting.site_appearance != 'auto'
      theme = current_user&.appearance || Setting.site_appearance
      return image_tag qrcode_udid_index_path(size: :md, theme: theme, format: :svg)
    end

    content_tag(:picture) do
      qrcode_uri = qrcode_udid_index_path(size: :md, theme: :dark, format: :svg)
      content_tag(:source, media: "(prefers-color-scheme: dark)", srcset: qrcode_uri) do
        image_tag qrcode_udid_index_path(size: :md, format: :svg)
      end
    end
  end
end
