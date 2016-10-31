# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'net/http'
require 'json'


# Seed the geo buildings

uri = URI.parse('http://campusmap.ufl.edu/library/cmapjson/geo_buildings.json')
response = Net::HTTP.get(uri)
data = JSON.parse(response)

data['features'].each do |feature|
    name = feature['properties']['NAME']
    puts "Name: #{name}"
end
