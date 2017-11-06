require 'test_helper'

class GamesControllerTest < ActionDispatch::IntegrationTest
  test "should get game" do
    get games_game_url
    assert_response :success
  end

  test "should get score" do
    get games_score_url
    assert_response :success
  end

end
