# Building class to easily insert into the database
<<<<<<< HEAD
class Building
  attr_reader :id, :outlets, :computers,
              :floors, :study_space,:object_id
  attr_accessor :connection 

  def initialize(id, outlets, computers, study_space, floors, object_id)
   @id = id
    @outlets = outlets
    @computers = computers
    @floors = floors
    @object_id = object_id 
    @study_space = study_space
    
    @connection = ActiveRecord::Base.connection
    insert
=======
  end

  private

  def insert
    @connection.execute("INSERT INTO building VALUES (#{@id}, #{@outlets}, #{@computers}, #{@study_space}, #{@floors}, #{@object_id})")
  end

