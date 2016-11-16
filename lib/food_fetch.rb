# my apologies for messy code
class Food_Fetch
  def initialize
    @page = Nokogiri::HTML(
    open("http://www.bsd.ufl.edu/dining/Hours/RegularHours.aspx"))

    data = @page.css('td.menuitems').text.squeeze("\n").split("\n")
    data = data.collect(&:strip).reject(&:empty?)
    data_arr = slice data
    restaurants = data_arr.each { |restaurant| to_restaurant restaurant }
  end

  def slice data
    data.reject(&:empty?)
    slices = Array.new
    index = 0
    i = 0
    data.each do |line|
      if !(line.include?('CLOSED') || line.include?('AM') || line.include?('PM'))
        if !line.include?('HOURS') && !line.include?('NOON')
            slices << data.slice(index, i - index)
            index = i
        end
      end
      i += 1
    end

    slices
  end

  def to_restaurant rest_arr
    name = rest_arr[0]
    
    Restaurant.new name
  end
end



#if line.include?('CLOSED') || (line.include?('AM') && line.include?('PM'))
#
#  next
#else
