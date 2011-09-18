require 'nokogiri'
require 'sequel'
require 'uri'
require 'json'
require 'net/http'
require 'spreadsheet'           
require 'open-uri'
require 'progressbar'

require './scraping.rb'
require './setup.rb'
require './areas.rb'
require './crime_scores.rb'
require './ethnicities.rb'
require './forces.rb'
require './stops_and_searches.rb'
require './normalised_stops_and_searches.rb'

# Connect to the database using Sequel, a lightweight DB wrapper.
DB = Sequel.connect 'sqlite://db.db'

# The level that we should get data for. Default is 13 - Local Authorities.
LEVEL_TYPE_ID = 13

# Drop our existing tables.
DB.tables.each {|table| DB.drop_table table }

# Setup the DB schema.
DatabaseSetup.setup

# Gets all of the areas in England and stores them in the DB.
Areas.get_areas

# Gets the Home Office crime score for each of the areas and stores them
# in the DB.
CrimeScores.get_crime_scores

# Get the population of each ethnicity in each area and store the data in the
# DB.
Ethnicities.get_ethnicities

# Get the police force for each area and store the data in the DB.
Forces.get_forces

# Get the number of stops and searches for each area and store them in the DB.
StopsAndSearches.get_stops_and_searches

# Use the data we collected above to estimate the number of stops and
# searches each ethnicity should have per area.
NormalisedStopsAndSearches.normalise_stops_and_searches