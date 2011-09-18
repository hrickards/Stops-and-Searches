class NormalisedStopsAndSearches
  def self.normalise_stops_and_searches
    # Get all LAs and their crime scores.
    crime_las = DB[:crime_scores]

    # Get all LAs and their police force.
    police_las = DB[:police_forces]
    
    # Get all LAs and their ethnicity data.
    ethnicity_las = DB[:ethnicities]
    
    # Get all forces and their stops and searches.
    forces_stops_searches = DB[:stops_and_searches]

    # Initialise a new array to store the LAs in.
    las = []

    # For each la we have crime data for...
    crime_las.each do |crime_la|
      # Get a nice crime score (normal crime score plus four; makes our
      # calculations a lot easier as we don't have to deal with negative
      # numbers).
      crime_score = crime_la[:crime_score] + 4

      # Find the corresponding police LA.
      police_la = police_las.filter(:area_id => crime_la[:area_id]).first
      # Add the LA to the array of LAs.
      las << {
        :area_id => crime_la[:area_id],
        :name => crime_la[:name],
        :crime_score => crime_score,
        :force => police_la[:force]
      }
    end
    
    # For each of the LAs we have gathered...
    las.each do |la|
      # Find all other LAs that have the same force. Based on http://stackoverflow.com/questions/2244915
      same_force_las = las.select { |f| f[:force] == la[:force] }
    
      # Initialise a variable to store the total crime score in.
      total_crime_score = 0
    
      # For each LA with the same force, add it's crime score to the total
      # crime score.
      same_force_las.collect {
        |same_force_la| total_crime_score += same_force_la[:crime_score]
      }
    
      # Caluclate the percentage of the total the current LA's crime score is.
      crime_score_percentage = la[:crime_score] / total_crime_score
    
      # Find the stops and searches data for the police force for the current
      # LA.
      force_stops_and_searches = forces_stops_searches.
        filter(:force => la[:force]).first[:total_stops_and_searches]
      
      # Calculate the expected number of stops and searches by multiplying the
      # crime score percentage by the number of stops and searches performed
      # in the police force.
      expected_stops_and_searches =
        crime_score_percentage * force_stops_and_searches
    
      # Find the ethnicity data for the LA. Note that we are cloning the hash
      # - when we delete keys we do not actually want to change any data in the
      # DB.
      ethnicity_la = ethnicity_las.filter(:area_id =>la[:area_id]).first.clone
    
      # Store the total number of people - this will be needed later to
      # calculate ethnic percentages.
      total_people = ethnicity_la[:all_people]
    
      # Calculate and store in the LA hash the expected numbers of stops and
      # searches for each ethnicity.
    
      # To do this, we'll first remove the area_id, name and all_people keys.
      # All# of the others should be ethnicities.
      ethnicity_la.delete :area_id
      ethnicity_la.delete :name
      ethnicity_la.delete :all_people

      # Next, iterate over the remaining keys in the ethnicity data.
      ethnicity_la.each_pair do |ethnicity_key, ethnicity_value|
        # Obtain the percentage of the ethnicity by dividing the number of
        # people of the ethnicity by the total number of people.
        percentage = ethnicity_value.to_f / total_people.to_f

        # Multiply the percentage by the expected number of stops and searches
        # to obtain the expected number of stops and searches for that
        # ethnicity, and store it in the LA hash.
        la[ethnicity_key] = percentage * expected_stops_and_searches
      end
  
      # Store the LA data in the database.
      DB[:normalised_stops_and_searches].insert la
    end
  end
end