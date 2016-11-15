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
    @connection.execute("INSERT INTO point_of_interest VALUES (#{@id}, '#{@type}', #{@object_id})")
  end

end
