class Areas
  def self.get_areas
    puts "Called"
    # The link to the URL containing the data. LevelTypeId is 13 - signifying
    # that we want to return local authorities and AreaId is 276693, the ID for
    # England.
    data_url = 'http://neighbourhood.statistics.gov.uk/NDE2/Disco/' + 
      'GetAreaAtLevel?LevelTypeId=#{LEVEL_TYPE_ID}&AreaId=276693'

    # Scrape the data.
    data = scrape data_url

    # Parse the scraped XML. Based upon http://nokogiri.org/
    doc = Nokogiri::XML.parse(data)

    # Get the data we need from the xml.
    areas = doc.css('ns2|GetAreaAtLevelResponseElement Areas').children
    # For each local authority...
    areas.each do |area|
      # Get the name and Area ID of the LA.
      name = area.css('Name').children.first.to_s
      area_id = area.css('AreaId').children.first.to_s

      # Generate a record from the LA.
      data = {
        :area_id => area_id,
        :name => name
      }
  
      # Save the data.
      DB[:areas].insert data
    end
  end
end