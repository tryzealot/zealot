# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

Mime::Type.register 'application/javascript', :pac
Mime::Type.register 'application/octet-stream', :plist
# Mime::Type.register 'image/png', :png

ActionController::Renderers.add :plist do |data, options|
  data = data.as_json(options) unless options[:skip_serialization] == true

  self.content_type ||= Mime::PLIST
  self.response_body = data.to_plist(convert_unknown_to_string: true)
end

ActionController::Renderers.add :qrcode do |string, options|
  data = RQRCode::QRCode.new(string).as_png(options)
  self.content_type ||= Mime[:png]
  self.response_body = render_to_string(text: data, template: nil)
end