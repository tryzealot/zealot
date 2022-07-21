# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register 'application/javascript', :pac
Mime::Type.register 'text/plist', :plist

Mime::Type.register 'application/vnd.iphone', :ipa
Mime::Type.register 'application/vnd.android.package-archive', :apk

ActionController::Renderers.add :qrcode do |content, options|
  data = RQRCode::QRCode.new(content).as_png(options)
  self.content_type ||= Mime[:png]
  self.response_body = render_to_string(plain: data, template: nil)
end
