class Restaurant_Seed
  attr_reader :rest_id, :name, :desc, :image_path, :object_id, :hours
  @@hour_id = 0
  def initialize id, name, desc, image_path, object_id, hours
    @rest_id = id
    @name = name
    @desc = desc
    @image_path = image_path
    @object_id = object_id
    @hours = hours

    @connection = ActiveRecord::Base.connection
    insert_restaurant
    insert_hours
  end

  def insert_restaurant
    @connection.execute("INSERT INTO restaurant VALUES (#{@rest_id}, '#{@desc}',  '#{@name}', '#{@image_path}', #{@object_id})" )
  end

  def insert_hours
    @hours.each do |day|
      begin
        @connection.execute("INSERT INTO open_hours VALUES (#{@@hour_id}, #{@object_id}, #{@rest_id}, '#{day.day}', #{day.open_hour}, #{day.close_hour})")
      rescue => error
        puts "FAILED TO ASSOCIATE HOUR WITH RESTAURANT. MISSING OBJECT_ID., #{error}"
      end
      @@hour_id += 1
    end
  end
end
