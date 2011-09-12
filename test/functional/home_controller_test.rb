require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get get_translation" do
    get :get_translation
    assert_response :success
  end

end
