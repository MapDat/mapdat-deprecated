# Point of interest class to easily insert points of interest into the database
#CREATE TABLE point_of_interest(
#      id      int NOT NULL,
#        type        VARCHAR (10),
#            object_id int NOT NULL,
#                PRIMARY KEY (id),
#                   FOREIGN KEY (object_id) REFERENCES map_object(id)
#);
class Poi
  attr_reader :id, :type, :object_id
  attr_accessor :connection

  def initialize(id, type, object_id)
    @id = id
    @type = type
    @object_id = object_id

    @connection = ActiveRecord::Base.connection
    insert
  end

  def insert
    @connection.execute("INSERT INTO point_of_interest VALUES (#{@id}, #{@type}, #{@object_id})")
  end

end
