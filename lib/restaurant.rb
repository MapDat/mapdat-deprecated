class Restaurant
  attr_reader :id, :name, :desc, :image_path, :object_id, :hours
  def initialize id, name, desc, image_path, object_id, hours
    @id = id
    @name = name
    @desc = desc
    @image_path = image_path
    @object_id = object_id
    @hours = hours
  end
end
