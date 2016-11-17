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
    unless object_id.nil?
      @connection.execute("INSERT INTO restaurant VALUES (#{@rest_id}, '#{@desc}',  '#{@name}', '#{@image_path}', #{@object_id})" )
    else
      @connection.execute("INSERT INTO restaurant VALUES (#{@rest_id}, '#{@desc}', '#{@name}', '#{@image_path}', '')")
    end
  end

  def insert_hours
    @hours.each do |day|
      @connection.execute("INSERT INTO rest_open_hours VALUES (#{@@hour_id}, #{@rest_id}, '#{day.day}', #{day.open_hour}, #{day.close_hour})")
      @@hour_id += 1
    end
  end
end
