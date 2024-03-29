# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# HOW TO USE: This file uses environment variables assigned at the task call in order to correctly
#             seed all aspects of the database.
#
#             rake:db seed seed_users=yes seed_restaurants=yes
#
#  seed_users, seed_restaurants, seed_map_objects, seed_reviews, seed_pop_times
#

require 'net/http'
require 'json'
require "building_seed.rb"
require "map_object_seed.rb"
require "poi_seed.rb"
require "geo_point_seed.rb"
require "day.rb"
require "restaurant_seed.rb"

num_users = 500
num_reviews = 5000

puts "Connecting to UF Oracle DB Servers."
@connection = ActiveRecord::Base.connection # Connect to the DB

###################################################
#       TABLE CREATION
###################################################

if ENV["seed_map_objects"]
  puts "Dropping existing tables."
  # Drop the existing tables
  begin
    puts "DROP TABLE geo_point CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE geo_point CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
  begin
    puts "DROP TABLE point_of_interest CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE point_of_interest CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
  begin
    puts "DROP TABLE building"
    @connection.execute("DROP TABLE building CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end

end

if ENV["seed_restaurants"]
  begin
    puts "DROP TABLE open_hours CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE open_hours CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
end

if ENV["seed_reviews"]
  begin
    puts "DROP TABLE reviews CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE reviews CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
end

if ENV["seed_users"]
  begin
    puts "DROP TABLE users CASCADE CONSTRAINTS "
    @connection.execute("DROP TABLE users CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
end

if ENV["seed_restaurants"]
  begin
    puts "DROP TABLE restaurant CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE restaurant CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
end

if ENV["seed_pop_times"]
  begin
    puts "DROP TABLE pop_times CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE pop_times CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
end

if ENV["seed_map_objects"]
  begin
    puts "DROP TABLE map_object CASCADE CONSTRAINTS"
    @connection.execute("DROP TABLE map_object CASCADE CONSTRAINTS")
  rescue => error
    puts error
  end
end

puts "Create Tables"
# Recreate our tables

if ENV["seed_map_objects"]
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
end

if ENV["seed_users"]
  puts "CREATE TABLE Users"
  @connection.execute("
    CREATE TABLE users(
      email 				VARCHAR (255) NOT NULL,
      first_name 			VARCHAR (255) NOT NULL,
      last_name 			VARCHAR (255) NOT NULL,
      encrypted_password 		VARCHAR (255) NOT NULL,
      img_path        VARCHAR(255),
      PRIMARY KEY (email)
    )")
end

if ENV["seed_reviews"]
  puts "CREATE TABLE reviews"
  @connection.execute("
    CREATE TABLE reviews(
      email 		VARCHAR (255),
      object_id	int,
      content 	VARCHAR (1000),
      review_date 	DATE,
      title 		VARCHAR (255),
      rating 	INT,
      PRIMARY KEY (email, object_id),
      FOREIGN KEY (email) REFERENCES Users(email),
      FOREIGN KEY (object_id) REFERENCES Map_Object(id)
    )")
end

if ENV["seed_restaurants"]
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
    CREATE TABLE open_hours(
    	id      		            int,
      object_id               int,
      rest_id                 int,
    	day 	                	VARCHAR(9),
    	open_time 	            int,
    	close_time 	            int,
    	PRIMARY KEY (id),
      FOREIGN KEY (object_id) REFERENCES map_object(id),
      FOREIGN KEY (rest_id) REFERENCES restaurant(id)
    )")
end

if ENV["seed_pop_times"]
  puts "CREATE TABLE pop_times"
  @connection.execute("
    CREATE TABLE pop_times(
      id                     int,
      object_id              int,
      day                    int,
      hour                   int,
      popularity             int,
      PRIMARY KEY(id),
      FOREIGN KEY(object_id) REFERENCES map_object(id)
    )")
end
###################################################
#       SEEDING
###################################################
# TODO: Currently only 'Polygon' type works. There is another type
# called MultiPolygon that needs supported

# Users
if ENV["seed_users"]
  i = 1
  num_users.times do
    first_name = Faker::Name.first_name.gsub(/'/, '')
    last_name = Faker::Name.last_name.gsub(/'/, '')
    email = Faker::Internet.email
    password = Faker::Internet.password
    puts i.to_s + ' ' + first_name + ' ' + last_name + ' ' + email + ' ' + password
    begin
      @connection.execute("INSERT INTO users VALUES(
                          '#{email}', '#{first_name}', '#{last_name}', '#{password}', 'default.jpg')")
      i += 1
    rescue => error
      puts 'Could not create record'
      puts error
    end
  end
end


# Seed buildings into the database

if ENV["seed_map_objects"]
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

    if props['DESCRIPTION'] == " "
      description = Faker::Lorem.paragraph
    else
      description = props['DESCRIPTION'].gsub(/'/, ' ')
    end
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
      w = Random.new.rand(0..50)
      x = Random.new.rand(0..1)
      y = Random.new.rand(0..1)
      z = Random.new.rand(0..6)

      Building_Seed.new(id, w, x, y, z, id)
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

end

if ENV["seed_restaurants"]

  # RESTAURANTS
  restaurants = YAML.load_file("#{Rails.root}/db/restaurants.yml")
  i = 0
  restaurants.each do |key, value|
  #  puts restaurants[key]
    object_id = @connection.exec_query("SELECT m.id FROM map_object m
                                        WHERE m.abbrev = '#{restaurants[key]['Location']}'")

    object_id = object_id.first["id"]
    puts key
    open_hours = []
    restaurants[key].each do |key, value|
      next if key == 'Location'
      day = Day.new(key, value["open"], value["close"])
      open_hours << day
      puts value["open"].to_s + ' ' + value["close"].to_s
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
end

obj_ids = @connection.exec_query("SELECT id FROM map_object").rows

if ENV["seed_reviews"]
  # Get object IDs for Reviews
  emails = @connection.exec_query("SELECT email FROM users").rows

  # Reviews
  i = 1
  num_reviews.times do
    email = emails.sample[0]
    object_id = obj_ids.sample[0]
    content = Faker::Lorem.paragraph
    review_date = Faker::Date.between(1.month.ago, Date.today)
    title = Faker::Lorem.sentence
    rating = rand(1..5)

    puts i.to_s + ' ' + email + ' ' + object_id.to_s + ' ' + content + ' ' + review_date.to_s + ' ' + title + ' ' + rating.to_s + ' ';
    begin
      @connection.execute("INSERT INTO reviews VALUES(
                          '#{email}', '#{object_id}', '#{content}', '#{review_date}', '#{title}', '#{rating}')")
      i += 1
    rescue => error
      puts 'Could not create record'
      puts error
    end
  end
end

if ENV["seed_pop_times"]
  i = 1
  obj_ids.each do |obj_id|
    7.times do |day|
      24.times do |hour|
        popularity = Random.new.rand(0..10)
        puts "New popular time: #{i}, #{obj_id[0]}, #{day}, #{hour}, #{popularity}"
        @connection.execute("INSERT INTO pop_times VALUES (
                            #{i}, #{obj_id[0]}, #{day}, #{hour}, #{popularity}
        )")
        i += 1
      end
    end
  end

end
