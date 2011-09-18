class Forces
  def self.get_forces

    # Get all LAs.
    las = DB[:areas]
    
    # Create a new progress bar.
    pbar = ProgressBar.new("Forces", las.count)

    # For each LA...
    las.each_with_index do |la, index|
      # Store an escaped version of the LA Name.
      la_name = URI.escape "#{la[:name]}, UK"

      # Generate a URL for geocoding the LA Name.
      geocode_url = "http://maps.googleapis.com/maps/api/geocode/json?" +
        "address=#{la_name}&sensor=false&region=uk"

      # Scrape the JSON, and parse it.
      json = JSON.parse scrape(geocode_url)

      # Store the lat/lng location of the LA.
      location = json["results"][0]["geometry"]["location"]
      lat = location["lat"]
      lng = location["lng"]

      # Generate a URL for locating the police authority from the lat/lng.
      police_url = "policeapi2.rkh.co.uk"
    
      # Check for some certain LAs - the police API returns a not found on them
      # for some reason. Instead, we'll just manually list it as being where
      # it is.
      if la[:area_id] == '276913' or la[:area_id] == '276914'
        force = 'cumbria'
      elsif la[:area_id] == '277018' or la[:area_id] == '276819'
        force = 'lancashire'
      elsif la[:area_id] == '277070'
        force = 'north-yorkshire'
      elsif la[:area_id] == '277083'
        force = 'nottinghamshire'
      elsif la[:area_id] == '277148'
        force = 'west-marcia'
      elsif la[:area_id] == '276748'
        force = 'metropolitan'
      else
        # Connect to the URL, authenticate and store the response in a string.
        # Based upon
        # http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTP.html

        req = Net::HTTP::Get.new "/api/locate-neighbourhood?q=#{lat},#{lng}"
        res = Net::HTTP.start(police_url) do |http|
          req.basic_auth POLICE_API_USERNAME, POLICE_API_TOKEN
          http.request(req)
        end
        
        # Parse the resonse as JSON and store it
        json = JSON.parse res.body
  
        # Store the force of the LA.
        force = json['force']
      end

      # Create a new hash storing the LA details, including the police force.
      la_hash = {
        :name => la[:name],
        :area_id => la[:area_id],
        :force => force
      }

      # Add the row to the datastore.
      DB[:police_forces].insert la_hash
      
      # Increment the progress bar.
      pbar.inc
    end
    
    # Stop the progress bar.
    pbar.finish
  end
end