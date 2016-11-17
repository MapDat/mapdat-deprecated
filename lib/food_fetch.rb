# Grabs the restaurants from bsd.ufl.edu and saves them in a file haphazardly
class Food_Fetch
  def initialize
    @page = Nokogiri::HTML(
    open("http://www.bsd.ufl.edu/dining/Hours/RegularHours.aspx"))
    data = @page.css('td.menuitems').text.squeeze("\n").split("\n")
    data = data.collect(&:strip).reject(&:empty?)
    File.open('test.txt', 'a') { |file| file.puts data }
  end
end
