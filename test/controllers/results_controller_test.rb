require "test_helper"

class ResultsControllerTest < ActionDispatch::IntegrationTest
  test "should get results" do
    get results_results_url
    assert_response :success
  end
end
