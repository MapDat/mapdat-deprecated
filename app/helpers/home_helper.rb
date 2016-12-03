module HomeHelper
  def get_object object_id
    @connection = ActiveRecord::Base.connection
    @object_info = @connection.exec_query("SELECT
                                                  m.id,
                                                  m.name,
                                                  m.abbrev,
                                                  m.description,
                                                  m.image_path,
                                                  b.number_of_outlets,
                                                  b.computers,
                                                  b.study_space,
                                                  b.number_of_floors
                                           FROM map_object m, building b
                                           WHERE b.object_id = m.id")

    @object_info.rows
  end
end
