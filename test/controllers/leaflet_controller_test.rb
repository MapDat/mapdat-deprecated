require 'test_helper'

class LeafletControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get leaflet_index_url
    assert_response :success
  end

end
