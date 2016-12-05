class HomeController < ApplicationController
  require 'json'
  require 'date'
  #before_filter :authorize

  def index
    @connection = ActiveRecord::Base.connection

    @zoom = 18




    if params[:show_poi] == "true"
      @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                         FROM map_object m, geo_point g, point_of_interest p
                                         WHERE g.object_id = m.id AND m.id = p.object_id
                                        ").rows
    elsif params[:show_south_study] == "true"
      @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude FROM map_object m, building, geo_point g
                                        WHERE building.object_id = g.object_id
                                        AND longitude < 29.645
                                        AND study_space = 1
                                        AND computers = 1
                                        AND m.id = building.object_id").rows
    elsif params[:show_query3] == "true"
      @objects = @connection.exec_query("SELECT b.object_id, g.longitude, g.latitude FROM building b, reviews, geo_point g, restaurant r
                                        WHERE b.object_id = reviews.object_id
                                        AND r.object_id = b.object_id
                                        AND g.object_id = b.object_id
                                        AND reviews.rating > 3
                                        AND (SELECT count(*) FROM restaurant re WHERE re.object_id = b.object_id) > 2
                                        ORDER BY rating
                                        DESC").rows
    elsif params[:show_food_and_study] == "true"
      @objects = @connection.exec_query("SELECT g.object_id, g.longitude, g.latitude FROM geo_point g
                                         WHERE g.object_id
                                         IN (SELECT r.object_id FROM building b, map_object m, restaurant r
                                         WHERE m.id = b.object_id
                                         AND m.id = r.object_id)").rows
    elsif params[:show_north_museum] == "true"
      @objects = @connection.exec_query("SELECT m.id, p.longitude, p.latitude
                                         FROM building b, map_object m, geo_point p
                                         WHERE m.id = b.object_id
                                         AND m.id = p.object_id
                                         AND p.longitude >= 29.6449").rows

    elsif params[:show_7am]
      @objects = @connection.exec_query("SELECT g.object_id, g.longitude, g.latitude FROM geo_point g
                                         WHERE g.object_id
                                         IN (SELECT r.object_id FROM restaurant r, open_hours h
                                         WHERE h.day = 'Tuesday'
                                         AND r.id = h.rest_id
                                         AND h.open_time <= 700)").rows

    elsif params[:show_best_places]
      @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                         FROM map_object m, geo_point g
                                         WHERE m.id = g.object_id AND m.id IN
                                         (SELECT r.object_id
                                         FROM reviews r GROUP BY r.object_id
                                         HAVING AVG(r.rating) > 4
                                         )")

    else
      @objects = @connection.exec_query("SELECT m.id, g.longitude, g.latitude
                                         FROM map_object m, geo_point g, building b
                                         WHERE g.object_id = m.id
                                         AND b.object_id = m.id
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


  def building_info
    @connection = ActiveRecord::Base.connection
    @building = '{}' unless params[:object_id]

    @building = @connection.exec_query("SELECT * FROM building b, map_object m
                                        WHERE m.id = b.object_id
                                        AND m.id = #{params[:object_id]}").first

    @available_restaurants = @connection.exec_query("SELECT r.name, o.day, o.open_time, o.close_time
                                                    FROM restaurant r, open_hours o, map_object m
                                                    WHERE o.rest_id = r.id
                                                    AND r.object_id = #{params[:object_id]}
                                                    AND r.object_id = m.id
                                                    AND o.day = '#{Date.today.strftime("%A")}'")

    @reviews = @connection.exec_query("SELECT r.title, r.content, r.review_date, r.rating, u.email, u.first_name, u.last_name, u.img_path
                                       FROM reviews r, map_object m, users u
                                       WHERE m.id = r.object_id
                                       AND m.id = #{params[:object_id]}
                                       AND u.email = r.email
                                       ORDER BY r.review_date DESC")

    @avg_review = @connection.exec_query("SELECT AVG(rating) AS avg_review FROM reviews WHERE object_id = #{params[:object_id]}").first["avg_review"]

    @review_group = @connection.exec_query("SELECT rating, count(rating) AS count FROM reviews WHERE object_id = #{params[:object_id]} GROUP BY rating ORDER BY rating DESC")

    days =  { "Sunday" => 0, "Monday" => 1, "Tuesday" => 2, "Wednesday" => 3, "Thursday" => 4, "Friday" => 5, "Saturday" => 6 }

    @pops = @connection.exec_query("SELECT hour, popularity FROM pop_times WHERE object_id = #{params[:object_id]} AND day = #{days[Date.today.strftime("%A")]}")

    hash = { building: @building.to_hash, restaurants: @available_restaurants.to_hash, avg_review: @avg_review, review_group: @review_group.to_hash, reviews: @reviews.to_hash, pop_times: @pops.to_hash }
    render json: JSON.pretty_generate(hash)
  end

  def add_review
    authorize
    @connection = ActiveRecord::Base.connection
    @connection.execute("INSERT INTO reviews VALUES ('#{session[:email]}', #{params[:user][:object_id]}, '#{params[:user][:content]}', to_date('#{Time.now.strftime('%Y%m%d')}', 'yyyymmdd'), '#{params[:user][:title]}', #{params[:user][:rating]})")
    redirect_to '/'
  end


  def show_poi
    redirect_to controller: 'home', action: 'index', show_poi: true
  end

  def hide_poi
    redirect_to controller: 'home', action: 'index', show_poi: false
  end

  def show_south_study
    redirect_to controller: 'home', action: 'index', show_south_study: true
  end

  def hide_south_study
    redirect_to controller: 'home', action: 'index', show_south_study: false
  end

  def show_query3
    redirect_to controller: 'home', action: 'index', show_query3: true
  end

  def hide_query3
    redirect_to controller: 'home', action: 'index', show_query3: false
  end

  def show_food_and_study
    redirect_to controller: 'home', action: 'index', show_food_and_study: true
  end

  def hide_food_and_study
    redirect_to controller: 'home', action: 'index', show_food_and_study: false
  end

  def show_north_museum
    redirect_to controller: 'home', action: 'index', show_north_museum: true
  end

  def hide_north_museum
    redirect_to controller: 'home', action: 'index', show_north_museum: false
  end

  def show_7am
    redirect_to controller: 'home', action: 'index', show_7am: true
  end

  def hide_7am
    redirect_to controller: 'home', action: 'index', show_7am: false
  end

  def show_best_places
    redirect_to controller: 'home', action: 'index', show_best_places: true
  end

  def hide_best_places
    redirect_to controller: 'home', action: 'index', show_best_places: false
  end

end
