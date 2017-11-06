require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def game
    @grid = generate_grid(10) # array of random 10 letters
  end

  def score
    grid = params[:grid].split("")
    start_time = Time.parse(params[:start_time])
    @output = run_game(params[:guess], grid, start_time, Time.now) # attempt, grid, start_time, end_time
  end

  def generate_grid(grid_size) # generate random grid of letters of defined size
    result = []
    grid_size.times { result << ("A".."Z").to_a.sample }
    return result
  end

  #------------------------------------#

  def compare_word_grid(char, word, grid) # 'word' and 'grid' are Arrays
    if grid.index(char)
      grid.delete_at(grid.index(char))
      word.delete_at(word.index(char))
    end
  end

  def in_grid(attempt, grid) # verifies if characters in attempt are included in grid
    try = attempt.split("")
    trying = try.dup
    try.each { |char| compare_word_grid(char, trying, grid) }
    if trying.empty?
      return "Yes"          # all letters in 'attempt' are in 'grid', great job.
    elsif trying == try
      return "No"           # no letters in 'attempt' are in 'grid'. Epic fail.
    else
      return "Partial"
    end
  end

  #------------------------------------#

  def api_to_hash(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    json = open(url).read
    api_to_hash = JSON.parse(json) # "found" true/false; "word" string ; "length" int
    api_to_hash["found"]
  end

  def message_based_on_api(api_to_hash, inside_grid)
    if api_to_hash == false
      "not an english word"
    elsif inside_grid == "Partial"
      "One or more characters used are not in the grid. Try again."
    elsif inside_grid == "Yes"
      "Well done!"
    end
  end

  def define_message(attempt, inside_grid) # requires 'in_grid' and 'api_to_hash'
    if inside_grid == "No"
      "Characters used are not in the grid. Try again."
    elsif ["Partial", "Yes"].include?(inside_grid)
      return message_based_on_api(api_to_hash(attempt), inside_grid)
    end
  end

  #------------------------------------#

  def score_time(time) # generates score based on time-to-answer
    case time
    when (0.0...3.0) then 10
    when (3.0...5.0) then 8
    when (5.0...7.0) then 6
    when (7.0...10.0) then 4
    when (10.0...15.0) then 2
    else 0
    end
  end

  def define_score(message, word, time) # requires 'define_message'
    score = 0
    if message[-6..-1] == "again." || message[-4..-1] == "word"
      return 0          # If word not found / Characters used not in grid
    else                # if word exists and characters used were all in the grid
      score += word.length      # word length component of score
      score += score_time(time) # time component of score
      return score
    end
  end

  #------------------------------------#

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    # this method will generate a hash with 3 key-value pairs: :time, :score, :message
    output = {}
    attempt.upcase!
    time_taken = end_time - start_time
    output[:time] = time_taken.round(2)
    output[:message] = define_message(attempt, in_grid(attempt, grid))
    output[:score] = define_score(output[:message], attempt, time_taken)
    return output
  end
end
