class HomeController < ApplicationController

  #before_filter :authorize

  def index
    @connection = ActiveRecord::Base.connection
    @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                       FROM map_object m, geo_point g
                                       WHERE g.object_id = m.id
                                      ")
    @objects.rows
  end
end
