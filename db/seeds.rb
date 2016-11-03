# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'net/http'
require 'json'
require "building.rb"
require "map_object.rb"


# Seed the geo buildings

uri = URI.parse('http://campusmap.ufl.edu/library/cmapjson/geo_buildings.json')
response = Net::HTTP.get(uri)
data = JSON.parse(response)
geo_buildings = []
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
  feature['geometry']['coordinates'].each do |point| 
    points << [point[0], point[1]]
  end


  prop_hash = { jtype: jtype, bldg_num: bldg_num, abbrev: abbrev,
                address: address, city: city, state: state,
                zip: zip, desc: description, url: url,
                remote_photo_path: photo, geo_points: points,
                name: name }
  
  puts prop_hash  
  geo_buildings << prop_hash
end



id = 0
geo_buildings.each do |geo_building| 
  begin
    Map_Object.new(id, geo_building[:name], geo_building[:desc], ' ')
    Building.new(id, 0, 1, 1, 5, id)    
    print '.'
  rescue => error
    puts error
    print '_'
  end
  id += 1
end

puts geo_buildings.count
puts id
