require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
   @letters = generate_grid(10)
   @now = Time.now
   @start_time = @now.min * 60 + @now.sec
  end

  def score
    @attempt = params[:attempt]
    @end = Time.now
    @letters = params[:letters].split("")
    @end_time = @end.min * 60 + @end.sec
    @start_time = params[:time].to_i
    @score = calculate_score(@attempt, @start_time, @end_time)
    @result = run_game(@attempt, @letters, @start_time, @end_time)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { Array('A'..'Z').sample }
  end

  def word_info(attempt)
    json = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    JSON.parse(json)
  end

  def in_grid?(attempt, grid)
    attempt.upcase.chars.all? { |letter| attempt.upcase.count(letter) <= grid.count(letter) }
  end

  def calculate_score(attempt, start_time, end_time)
    if word_info(attempt)["length"] != nil
      word_info(attempt)["length"] + (100 - (end_time - start_time))
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    if in_grid?(attempt, grid) && word_info(attempt)["found"]
      { time: end_time - start_time, score: @score, message: "Well done!" }
    elsif in_grid?(attempt, grid) && !word_info(attempt)["found"]
      { time: end_time - start_time, score: 0, message: "Not an English word" }
    else
      { time: end_time - start_time, score: 0, message: "Not in the grid" }
    end
  end
end
