# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
#
require 'net/http'
require 'json'
require "building.rb"
require "map_object.rb"
require "poi.rb"
require "geo_point.rb"

# buildings

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
  puts "ITEM: "
  feature['geometry']['coordinates'][0].each do |point|
    if shape == 'Polygon'

      points << [point[1], point[0]] # latitude, longitude
      puts "#{point[1]}, #{point[0]}"
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
    Map_Object.new(id, geo_building[:name], geo_building[:desc], ' ')
    Building.new(id, 0, 1, 1, 5, id)
    geo_building[:geo_points].each do |geo_point|
      Geo_Point.new(geo_id, geo_point[1], geo_point[0], id)
      geo_id += 1
    end
    print '.'
  rescue => error
    puts error
    print '_'
  end
  id += 1
end

id += 1

###############################################
# points of interest

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

  puts "ITEM: "
  feature['geometry']['coordinates'][0].each do |point|
    if shape == 'Polygon'

      points << [point[1], point[0]] # latitude, longitude
      puts "#{point[1]}, #{point[0]}"
    end
  end

  prop_hash = { name: name, desc: description, type: type, geo_points: points }
  #puts prop_hash
  geo_pois << prop_hash
end

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

  puts "ITEM: "
  feature['geometry']['coordinates'][0].each do |point|
    if shape == 'Polygon'

      points << [point[1], point[0]] # latitude, longitude
      puts "#{point[1]}, #{point[0]}"
    end
  end

  prop_hash = { name: name, desc: description, type: type, geo_points: points }
  #puts prop_hash
  geo_pois << prop_hash
end


# Insert map objects and points of interest
geo_pois.each do |geo_poi|
  begin
    Map_Object.new(id, geo_poi[:name], geo_poi[:desc], ' ')
    Poi.new(id, geo_poi[:type], id)
    puts geo_poi[:name]
    geo_poi[:geo_points].each do |geo_point|
      Geo_Point.new(geo_id, geo_point[1], geo_point[0], id)
      puts "#{geo_point[0]}, #{geo_point[1]}"
      geo_id += 1
    end
    print '.'
  rescue => error
    puts error
    print '_'
  end
  id += 1
end
