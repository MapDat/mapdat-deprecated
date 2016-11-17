require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get buildings" do
    get home_buildings_url
    assert_response :success
  end

  test "should get points_of_interest" do
    get home_points_of_interest_url
    assert_response :success
  end

end
