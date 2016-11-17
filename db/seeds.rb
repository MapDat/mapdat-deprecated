# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
#
require 'net/http'
require 'json'
require "building_seed.rb"
require "map_object_seed.rb"
require "poi_seed.rb"
require "geo_point_seed.rb"
require "day.rb"
require "restaurant_seed.rb"

puts "Connecting to UF Oracle DB Servers."
@connection = ActiveRecord::Base.connection # Connect to the DB

###################################################
#       TABLE CREATION
###################################################

puts "Dropping existing tables."
# Drop the existing tables
begin
  puts "DROP TABLE geo_point"
  @connection.execute("DROP TABLE geo_point")
rescue => error
  puts error
end
begin
  puts "DROP TABLE point_of_interest"
  @connection.execute("DROP TABLE point_of_interest")
rescue => error
  puts error
end
begin
  puts "DROP TABLE building"
  @connection.execute("DROP TABLE building")
rescue => error
  puts error
end
begin
  puts "DROP TABLE rest_open_hours"
  @connection.execute("DROP TABLE rest_open_hours")
rescue => error
  puts error
end
begin
  puts "DROP TABLE restaurant"
  @connection.execute("DROP TABLE restaurant")
rescue => error
  puts error
end
begin
  puts "DROP TABLE map_object"
  @connection.execute("DROP TABLE map_object")
rescue => error
  puts error
end



puts "Create Tables"
# Recreate our tables


puts "CREATE TABLE map_object"
# Must come before all dependent tables
@connection.execute("
  CREATE TABLE map_object(
    id                      int NOT NULL,
    name 		                VARCHAR(255),
    abbrev                  VARCHAR(255),
    description 	          VARCHAR2(4000),
  	image_path 	            VARCHAR (255),
    PRIMARY KEY(id)
  )")

puts "CREATE TABLE building"
@connection.execute("
  CREATE TABLE building(
    id 		                   int NOT NULL,
    number_of_outlets 	     int,
    computers 		           int,
    study_space 		         int,
    number_of_floors 	       int,
    object_id                int NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (object_id)  REFERENCES map_object(id)
  )")

puts "CREATE TABLE point_of_interest"
@connection.execute("
  CREATE TABLE point_of_interest(
    id 		                  int NOT NULL,
    type 		                VARCHAR (255),
    object_id               int NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (object_id) REFERENCES map_object(id)
  )")

puts "CREATE TABLE geo_point"
@connection.execute("
  CREATE TABLE Geo_Point(
  	id 	                   int NOT NULL,
  	longitude 	           Decimal(9,6),
  	latitude 	             Decimal(9,6),
    object_id              int NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (object_id) REFERENCES map_object(id)
  )")


puts "CREATE TABLE restaurant"
@connection.execute("
  CREATE TABLE restaurant(
    id 		                 int,
    description 	         VARCHAR2 (4000),
    name 		               VARCHAR (255) NOT NULL,
    image_path             VARCHAR (255),
    object_id              int,
    PRIMARY KEY (id),
    FOREIGN KEY (object_id) REFERENCES map_object(id)
  )")
puts "CREATE TABLE open_hours"
@connection.execute("
  CREATE TABLE rest_open_hours(
  	id      		            int,
    rest_id                 int,
  	day 	                	VARCHAR(9),
  	open_time 	            int,
  	close_time 	            int,
  	PRIMARY KEY (id),
    FOREIGN KEY (rest_id) REFERENCES restaurant(id)
  )
")

###################################################
#       SEEDING
###################################################
# TODO: Currently only 'Polygon' type works. There is another type
# called MultiPolygon that needs supported

# Seed buildings into the database

puts 'Seeding buildings'
# Get the buildings from the campus map
uri = URI.parse('http://campusmap.ufl.edu/library/cmapjson/geo_buildings.json')
response = Net::HTTP.get(uri)
data = JSON.parse(response)
geo_buildings = []

# Build a hash for each building
data['features'].each do |feature|
  props = feature['properties']
  jtype = props['JTYPE']
  bldg_num = props['BLDG']
  abbrev = props['ABBREV']
  name = props['NAME']
  address = props['ADDRESS1']
  city = props['CITY']
  state = props['STATE']
  zip = props['ZIP']
  description = props['DESCRIPTION']
  url = props['URL']
  photo = props['PHOTO']

  shape =  feature['geometry']['type']
  points = []
  # puts "ITEM: "
  feature['geometry']['coordinates'][0].each do |point|
    if shape == 'Polygon'

      points << [point[1], point[0]] # latitude, longitude
      # puts "#{point[1]}, #{point[0]}"
    end
  end


  prop_hash = { jtype: jtype, bldg_num: bldg_num, abbrev: abbrev,
                address: address, city: city, state: state,
                zip: zip, desc: description, url: url,
                remote_photo_path: photo, geo_points: points,
                name: name }

 # puts prop_hash
  geo_buildings << prop_hash
end


# Insert map objects, buildings, and geo_points
id = 0
geo_id = 0
geo_buildings.each do |geo_building|
  begin
    Map_Object_Seed.new(id, geo_building[:name], geo_building[:abbrev], geo_building[:desc], ' ')
    Building_Seed.new(id, 0, 1, 1, 5, id)
    geo_building[:geo_points].each do |geo_point|
      Geo_Point_Seed.new(geo_id, geo_point[1], geo_point[0], id)
      geo_id += 1
    end
    puts geo_building[:name]
  rescue => error
    puts error
    print '_'
  end
  id += 1
end
id += 1


puts 'Seeding points of interest'
# Seed points of interest
# Currently urban parks and natural areas are the only POI

puts '    --> Urban Parks'
# Get urban parks from the campus map
uri = URI.parse('http://campusmap.ufl.edu/library/cmapjson/urban_parks.json')
response = Net::HTTP.get(uri)
data = JSON.parse(response)
geo_pois = []

# Build a hash for each item
data['features'].each do |feature|
  props = feature['properties']
  name = props['NAME']
  type = props['JTYPE']
  description = props['DESCRIPTION']
  shape = feature['geometry']['type']
  points = []

  # puts "ITEM: "
  feature['geometry']['coordinates'][0].each do |point|
    if shape == 'Polygon'

      points << [point[1], point[0]] # latitude, longitude
      # puts "#{point[1]}, #{point[0]}"
    end
  end

  prop_hash = { name: name, desc: description, type: type, geo_points: points }
  #puts prop_hash
  geo_pois << prop_hash
end

puts '    --> Natural Areas'
# Get natural areas from campus map
uri = URI.parse('http://campusmap.ufl.edu/library/cmapjson/natural_areas.json')
response = Net::HTTP.get(uri)
data = JSON.parse(response)

# Build a hash for each item
data['features'].each do |feature|
  props = feature['properties']
  name = props['NAME']
  type = props['JTYPE']
  description = props['DESCRIPTION']
  shape = feature['geometry']['type']
  points = []

  # puts "ITEM: "
  feature['geometry']['coordinates'][0].each do |point|
    if shape == 'Polygon'

      points << [point[1], point[0]] # latitude, longitude
      # puts "#{point[1]}, #{point[0]}"
    end
  end

  prop_hash = { name: name, desc: description, type: type, geo_points: points }
  #puts prop_hash
  geo_pois << prop_hash
end


# Insert map objects and points of interest
geo_pois.each do |geo_poi|
  begin
    Map_Object_Seed.new(id, geo_poi[:name], '', geo_poi[:desc], ' ')
    Poi_Seed.new(id, geo_poi[:type], id)
    geo_poi[:geo_points].each do |geo_point|
      Geo_Point_Seed.new(geo_id, geo_point[1], geo_point[0], id)
      puts "#{geo_point[0]}, #{geo_point[1]}"
      geo_id += 1
    end
    puts geo_poi[:name]
  rescue => error
    puts error
    print '_'
  end
  id += 1
end

# RESTAURANTS
restaurants = YAML.load_file("#{Rails.root}/db/restaurants.yml")
i = 0
restaurants.each do |key, value|
#  puts restaurants[key]
  object_id = @connection.exec_query("SELECT m.id FROM map_object m
                                      WHERE m.abbrev = '#{restaurants[key]['Location']}'")

  if object_id.first.nil?
    object_id = nil
  else
    object_id = object_id.rows[0][0]
  end
  puts key
  open_hours = []
  restaurants[key].each do |key, value|
    next if key == 'Location'
    day = Day.new(key, value["open"], value["close"])
    open_hours << day
  end

  begin
    Restaurant_Seed.new(i, key, '', '', object_id, open_hours)
  rescue => error
    puts error
    print '_'
  end

  i += 1
  #Restaurant.new restaurant[key], '', '',
end
