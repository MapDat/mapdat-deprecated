class HomeController < ApplicationController
  require 'json'
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
                                         FROM map_object m, geo_point g, building b
                                         WHERE g.object_id = m.id
                                         AND b.object_id = m.id
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
      @polylines[object_id][:options] = { "clickable" => "true",
                                          "className" => object_id.to_s,
                                          "fill" => true ,
                                          "fillColor" => "#ff8080",
                                          "fillOpacity" => "0.5",
                                          "weight" => "3"
                                        }
    end

    @polylines = @polylines.reject { |e| e.to_s.empty? }
  end

  def show_poi
    redirect_to controller: 'home', action: 'index', show_poi: true, zoom: params[:zoom]
  end

  def hide_poi
    redirect_to controller: 'home', action: 'index', show_poi: false, zoom: params[:zoom]
  end

  def building_info
    @connection = ActiveRecord::Base.connection
    @building = '{}' unless params[:object_id]

    @building = @connection.exec_query("SELECT * FROM building b, map_object m
                                        WHERE m.id = b.object_id
                                        AND m.id = #{params[:object_id]}").first

    @reviews = @connection.exec_query("SELECT r.title, r.content, r.review_date, r.rating, u.email, u.first_name, u.last_name, u.img_path
                                       FROM reviews r, map_object m, users u
                                       WHERE m.id = r.object_id
                                       AND m.id = #{params[:object_id]}
                                       AND u.email = r.email")

    @avg_review = @connection.exec_query("SELECT AVG(rating) AS avg_review FROM reviews WHERE object_id = #{params[:object_id]}").first["avg_review"]

    @pop_times = {}
    7.times do |day|
      pops = @connection.exec_query("SELECT hour, popularity FROM pop_times WHERE object_id = #{params[:object_id]} AND day = #{day}")

      case day
      when 0
        @pop_times[:sunday] = pops.to_hash
      when 1
        @pop_times[:monday] = pops.to_hash
      when 2
        @pop_times[:tuesday] = pops.to_hash
      when 3
        @pop_times[:wednesday] = pops.to_hash
      when 4
        @pop_times[:thursday] = pops.to_hash
      when 5
        @pop_times[:friday] = pops.to_hash
      when 6
        @pop_times[:saturday] = pops.to_hash
      end
    end



    hash = { building: @building.to_hash, avg_review: @avg_review, reviews: @reviews.to_hash, pop_times: @pop_times.to_hash }
    render json: JSON.pretty_generate(hash)
  end
end
