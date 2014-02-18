json.array!(@api_mesafijas) do |api_mesafija|
  json.extract! api_mesafija, :id
  json.url api_mesafija_url(api_mesafija, format: :json)
end
