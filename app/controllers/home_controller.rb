class HomeController < ApplicationController

  #before_filter :authorize

  def index
    @connection = ActiveRecord::Base.connection
    @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                       FROM map_object m, geo_point g
                                       WHERE g.object_id = m.id
                                      ").rows

    @polylines = []
    @objects.each do |object|
      object_id = object[0]
      if @polylines[object_id].nil?
        @polylines[object_id] = Hash.new
        @polylines[object_id][:latlngs] = []
      end
      @polylines[object_id][:latlngs] << [object[1], object[2]]
    end

    @polylines = @polylines.reject { |e| e.to_s.empty? }
  end

end
