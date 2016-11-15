# object for holding geo_points and inserting them into the database
class Geo_Point
  attr_reader :id, :longitude, :longitude, :object_id
  attr_accessor :connection

  def initialize(id, longitude, latitude, object_id)
    @id = id
    @longitude = longitude
    @latitude = latitude
    @object_id = object_id

    @connection = ActiveRecord::Base.connection
    insert
  end

  def insert
    @connection.execute("INSERT INTO geo_point VALUES (#{@id}, #{@latitude}, #{@longitude}, #{@object_id})")
  end

end
