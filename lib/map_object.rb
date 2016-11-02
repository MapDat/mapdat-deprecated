# main object class for inserting into the databas
class Map_Object
    attr_reader :id, :name, :description, :image_path
    attr_accessor :connection

    def initialize(id, name, description, image_path)
      @id = id
      @name = name
      @description = description
      @image_path = image_path 

      @connection = ActiveRecord::Base.connection
      insert
    end

    def insert
     @connection.execute("INSERT INTO map_object VALUES (#{@id},'#{@name}','#{@description}','#{@image_path}')") 
    end

end
