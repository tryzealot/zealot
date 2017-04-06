class Api::PacsSerializer < Api::BaseSerializer
  attributes :host, :port, :url, :created_at, :updated_at

  def url
    "#{pac_url(object.id)}.pac"
  end
end
