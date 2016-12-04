class HomeController < ApplicationController

  #before_filter :authorize

  def index
    @connection = ActiveRecord::Base.connection


    if params[:zoom]
      @zoom = params[:zoom]
    else
      @zoom = 18
    end

    logger.info params[:show_poi]
    if params[:show_poi] == 'false' || params[:show_poi].nil?
      @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                         FROM map_object m, geo_point g
                                         WHERE g.object_id = m.id
                                        ").rows
    else
      @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                         FROM map_object m, geo_point g, point_of_interest p
                                         WHERE g.object_id = m.id AND m.id = p.object_id
                                        ").rows
    end

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

  def show_poi
    redirect_to controller: 'home', action: 'index', show_poi: true, zoom: params[:zoom]
  end

  def hide_poi
    redirect_to controller: 'home', action: 'index', show_poi: false, zoom: params[:zoom]
  end
end
