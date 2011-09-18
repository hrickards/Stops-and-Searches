def scrape (url)
  return Net::HTTP.get_response(URI.parse(url)).body
end