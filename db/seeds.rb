# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'net/http'
require 'json'

# Lets us execute SQL
orcl = ActiveRecord::Base.connection

# Seed the geo buildings

uri = URI.parse('http://campusmap.ufl.edu/library/cmapjson/geo_buildings.json')
response = Net::HTTP.get(uri)
data = JSON.parse(response)
geo_buildings = []

count = 0
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
  url = props['url']
  photo = props['PHOTO']
  

  shape =  feature['geometry']['type']

  points = []
  feature['geometry']['coordinates'].each do |point| 
    points << [point[0], point[1]]
    count += 1
  end


  prop_hash = { jtype: jtype, bldg_num: bldg_num, abbrev: abbrev,
                address: address, city: city, state: state,
                zip: zip, desc: description, url: url,
                remote_photo_path: photo, geo_points: points }

end


puts orcl.exec_query("SELECT * FROM building")

geo_buildings.each do |geo_building|
  puts "INSERTING #{geo_building}"
    orcl.execute("INSERT INTO Building (id, number_of_outlets, computers, study_space, number_of_floors
                 VALUES (#{geo_building[:bld_num]}, 0, 0, 0, 0)")
end
