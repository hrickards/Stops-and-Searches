class Ethnicities
  def self.get_ethnicities
    # Get all LAs
    las = DB[:areas]
    
    # Create a new progress bar.
    pbar = ProgressBar.new("Ethnicities", las.count)

    # For each LA...
    las.each do |la|  
      # Get the name and AreaID
      name = la[:name]
      area_id = la[:area_id]

      # Generate a URL to get the ethnicity data from.
      url = "http://neighbourhood.statistics.gov.uk/NDE2/Deli/getTables?" +
      "Areas=#{area_id}&Datasets=87"

      # Get the data from the URL, and parse it as xml.
      doc = Nokogiri::XML.parse scrape(url)
      # Remove all namespaces from the doc - one seems to be declared invalidly
      # and is messing things up.
      doc.remove_namespaces!

      # Get the relevant section of the doc.
      relevant_data = doc.css('getDataCubeResponseElement Datasets Dataset')

      # Initialise a dataset to store the LA data in with some basic data.
      data = {
        :area_id => area_id,
        :name => name
      }

      # For each dataset item...
      relevant_data.css('DatasetItems').children.each do |item|
        # Get the topic id and value.
        topic_id = item.css('TopicId').children.first.to_s
        value = item.css('Value').children.first.to_s
  
        # Get the topic with the same topic id.
        topic = relevant_data.xpath("//Topics//Topic[TopicId=#{topic_id}]")
  
        # Get the title from the topic, and format it.
        title = topic.css('Title').children.first.to_s.downcase.gsub(' ', '_')
  
        # If title includes a colon it is a subcategory - for the moment we're just
        # ignoring these.
        unless title.include? ':'
          # Add the dataset item to the data we're going to store.
          data[title.to_sym] = value
        end
      end
  
      # Add the data to the datastore.
      DB[:ethnicities].insert data
      
      # Increment the progress bar.
      pbar.inc
    end
    
    # Stop the progress bar.
    pbar.finish
  end
end