class HomeController < ApplicationController

  #before_filter :authorize

  def index
    logger.info @current_user
    @connection = ActiveRecord::Base.connection
    @buildings = @connection.exec_query("SELECT m.id,
                                                m.name,
                                                m.abbrev,
                                                b.number_of_outlets,
                                                b.computers,
                                                b.study_space,
                                                m.description,
                                                m.image_path
                                         FROM building b, map_object m
                                         WHERE b.object_id = m.id")

    @coordinates = @connection.exec_query("SELECT longitude, latitude, object_id
                                           FROM geo_point")

    # [m.id, m.name, m.abbrev, b.number_of_outlets, b.computers,
    #  b.study_space, m.description, m.image_path ]
    @output = []
    @buildings.rows.each do |row|
      points = []
      @coordinates.rows.each do |coordinate|
        if coordinate[2] == row[0]
          points << {
                      latitude: coordinate[0],
                      longitude: coordinate[1],
                    }
        end
      end

      building_hash = {
                        id:                 row[0],
                        name:               row[1],
                        abbrev:             row[2],
                        description:        row[6],
                        number_of_outlets:  row[3],
                        computers:          row[4],
                        study_space:        row[5],
                        image_path:         row[7],
                        geo_points:         points
                      }

      @output << building_hash
    end
    logger.info @output
    @output
  end
end
