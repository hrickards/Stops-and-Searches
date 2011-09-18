class CrimeScores
  def self.get_crime_scores
    # Get all LAs.
    las = DB[:areas]
    
    # Create a new progress bar.
    pbar = ProgressBar.new("Crime Scores", las.count)

    # For each LA...
    las.each_with_index do |la, index|
  
      # Get the name and AreaID
      name = la[:name]
      area_id = la[:area_id]

      # Generate a URL to get the crime data from.
      url =
      "http://neighbourhood.statistics.gov.uk/NDE2/Deli/getChildAreaTables?" +
        "ParentAreaId=#{area_id}&LevelTypeId=141&Datasets=2307"

      # Get the data from the URL, and parse it as xml.
      doc = Nokogiri::XML.parse scrape(url)
      # Remove all namespaces from the doc - one seems to be declared invalidly
      # and is messing things up.
      doc.remove_namespaces!

      # Get the relevant section of the doc.
      relevant_data = doc.css('getDataCubeResponseElement Datasets Dataset')

      # Find the topic with title "Crime Score".
      topic = relevant_data.
        xpath("//Topics//Topic[TopicMetadata//Title='Crime Score']")
        
      # Get the topic ID we need to find data for.
      topic_id = topic.css('TopicId').children.first.to_s
      
      # Get the dataset items for the crime score.
      crime_score_items =
        relevant_data.xpath("//DatasetItems//DatasetItem[TopicId=#{topic_id}]")

      # Initialise an array to score the crime scores in.
      crime_scores = []

      # For each dataset item that is for the crime score...
      crime_score_items.each do |item|
        # Add the new crime score to the array of crime scores.
        crime_scores << item.css('Value').children.first.to_s.to_f
      end

      # Calculate the average crime score and add four to it (we don't want
      # negative crime scores).
      # Copied from http://stackoverflow.com/questions/1341271
      crime_score =
        (crime_scores.inject{ |sum, el| sum + el }.to_f / crime_scores.size)

      # If crime_scores is empty, set crime_score to 0 
      crime_score = 0 if crime_scores.empty? 

      # Create a hash to store the LA data in with some basic data.
      data = {
        :area_id => area_id,
        :name => name,
        :crime_score => crime_score
      }

      # Add the data to the datastore.
      DB[:crime_scores].insert data
      
      # Increment the progress bar.
      pbar.inc
    end
    
    # Stop the progress bar.
    pbar.finish
  end
end