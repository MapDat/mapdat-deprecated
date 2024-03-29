
# main object class for inserting into the databas
class Map_Object_Seed
  attr_reader :id, :name, :abbrev, :description, :image_path
  attr_accessor :connection

  def initialize(id, name, abbrev, description, image_path)
    @id = id
    @name = name
    @description = description
    @image_path = "default_building.jpg"
    @abbrev = abbrev

    @connection = ActiveRecord::Base.connection
    insert
  end

  def insert
    @connection.execute("INSERT INTO map_object VALUES (#{@id},'#{@name}', '#{@abbrev}', '#{@description}','#{@image_path}')")
  end
end
