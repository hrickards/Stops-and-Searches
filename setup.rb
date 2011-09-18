class DatabaseSetup
  def self.setup
    # Create tables which we can store the data in.
    DB.create_table :areas do
      primary_key :id
      String :area_id
      String :name
    end

    DB.create_table :ethnicities do
      primary_key :id
      String :area_id
      String :name
      String :chinese_or_other_ethnic_group
      String :asian_or_asian_british
      String :black_or_black_british
      String :all_people
      String :mixed
      String :white
    end

    DB.create_table :crime_scores do
      primary_key :id
      String :area_id
      String :name
      Float :crime_score
    end

    DB.create_table :police_forces do
      primary_key :id
      String :area_id
      String :name
      String :force
    end
    
    DB.create_table :stops_and_searches do
      primary_key :id
      String :force
      Integer :total_stops_and_searches
    end
    
    DB.create_table :normalised_stops_and_searches do
      primary_key :id
      String :area_id
      String :name
      String :force
      Float :chinese_or_other_ethnic_group
      Float :asian_or_asian_british
      Float :black_or_black_british
      Float :mixed
      Float :white
      Float :crime_score
    end
  end
end