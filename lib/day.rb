class Day
  attr_accessor :day, :open_hour, :close_hour
  def initialize(day, open_hour, close_hour)
    @day = day
    @open_hour = open_hour
    @close_hour = close_hour
  end

  def day
    @day
  end

  def open_hour
    @open_hour
  end

  def close_hour
    @close_hour
  end

end
