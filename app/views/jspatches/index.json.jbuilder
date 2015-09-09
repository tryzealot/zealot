json.array!(@jspatches) do |jspatch|
  json.extract! jspatch, :id
  json.url jspatch_url(jspatch, format: :json)
end
