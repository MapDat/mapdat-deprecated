class HomeController < ApplicationController
  def index
    @connection = ActiveRecord::Base.connection

    @buildings = @connection.exec_query("SELECT * FROM building b, map_object m, geo_point g
                                         WHERE b.object_id = m.id AND g.object_id = m.id")



    buildings = []
    @buildings.rows.each do |building|
      buildings << [building[7], building[8], building[9], '', 0, 0, 0, 0]
    end
    puts buildings
    render component: 'Building', props: { buildings: @buildings[0..100]}, tag: 'span', class: 'home'
  end


end
