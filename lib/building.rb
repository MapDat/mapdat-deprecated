# Building class to easily insert into the database


class Building
  attr_reader :id, :outlets, :computers,
              :floors, :object_id
  @connection = ActiveRecord::Base.connection

  def initialize(id, outlets, computers, floor, object_id)
    @id = id
    @outlets = outlets
    @computers = computers
    @floors = floors
    @object_id = object_id 
    
    insert()
  end

  private

  def insert()
     
  end

end

