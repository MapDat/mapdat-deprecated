class HomeController < ApplicationController
  def index
    @connection = ActiveRecord::Base.connection

    @buildings = @connection.exec_query("SELECT * FROM building b, map_object m
                                        WHERE b.object_id = m.id")

    buildings = []
    @buildings.rows.each do |building|
      buildings << [building[7], building[8], building[9], '', 0, 0, 0, 0]
    end
    puts buildings
    render component: 'Building', props: { buildings: buildings}, tag: 'span', class: 'home'
  end


end
