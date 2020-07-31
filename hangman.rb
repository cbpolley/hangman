require 'csv'
require 'json'

class Hangman
  attr_accessor :user_guess
  attr_accessor :secret_word_arr
  attr_accessor :wrong_guess_arr
  attr_accessor :wrong_guess

  def initialize
  end

  def load_up(user_guess, secret_word_arr, wrong_guess_arr)
    @secret_word_arr = secret_word_arr
    @user_guess = user_guess
    @wrong_guess_arr = wrong_guess_arr
  end

  def fresh_start
    @secret_word_arr = []
    @user_guess = []
    @wrong_guess_arr = []
    @secret_word = secret_word.downcase
    word_to_arr
  end

  def player_name
    puts 'What is your name?'
    name = gets.chomp
    @player_name = name
    puts "Hi #{@player_name}, welcome to hangman."
  end

  def main_screen
    puts "The word is:\n\n"
    @user_guess.each do |letter|
      print "#{letter} "
    end
    puts "\n\n"
    (6 - @wrong_guess_arr.length) == 1 ? guessword = 'guess' : guessword = 'guesses'
    puts "You have #{6 - @wrong_guess_arr.length} #{guessword} remaining.\n\n"
    puts "You have guessed these incorrect letters: #{@wrong_guess_arr}\n\n" if @wrong_guess_arr.empty? == false
    puts 'type save to save the game'
  end

  def end_game
    @wrong_guess == false ? contents = 'Hooray, you won!' : contents = "Uh oh, you lost!\n\nThe word was : #{@secret_word}"
    contents
  end

  def win_condition
    if @user_guess.difference(@secret_word_arr).any? == false || @wrong_guess_arr.length == 6 
      ending = true
    else
      ending = false
    end
    ending
  end

  def play_turn(user_input)
    @guess = "#{user_input} "
    @wrong_guess = true
    @secret_word_arr.each_with_index do |letter, index|
      next if @guess != letter

      @wrong_guess = false
      @secret_word_arr[index] != @user_guess[index] ? @user_guess[index] = "#{@guess}" : false
    end
    @wrong_guess_arr.push(@guess) if @wrong_guess == true && @wrong_guess_arr.include?(@guess) == false
    main_screen
  end

  def word_to_arr
    @secret_word .each_char do |letter|
      @secret_word_arr.push("#{letter} ")
      @user_guess.push('_')
    end
  end

  # private

  def secret_word
    countlines = 0
    lines = File.readlines '5desk.txt'
    lines.each do
      countlines += 1
    end
    word_choose = lines[rand(countlines).to_i].strip
    word_choose = lines[rand(countlines).to_i].strip until word_choose.size > 4 && word_choose.size < 13

    word_choose
  end
end

class SaveGame
  def initialize(game)
    Dir.mkdir('save_games') unless Dir.exist? 'save_games'
    filename = "../hangman/save_games/hangman_#{player_name}_#{find_hour}.json"
    File.open(filename, 'w') do |file|
      json = [game.user_guess, game.secret_word_arr, game.wrong_guess_arr].to_json
      file.puts json
    end
  end

  def find_hour
    registered_hour = DateTime.now().to_s.split('T')
    registered_hour = registered_hour[1]
    registered_hour[0..4]
  end
end

def load_game
  fileArr = []
  i = 0
  Dir.foreach('../hangman/save_games') do |filename|
    next if filename == '.' || filename =='..'
    i += 1
    fileArr.push("#{i} #{filename}")
  end
  return if fileArr.empty?

  puts 'Type the number of the save you want to load:'
  puts fileArr
  get_save = gets.chomp.to_i
  until get_save >= 1 && get_save <= fileArr.length
    puts 'Sorry, that number doesn\'t relate to a save file. Please try again.'
    puts fileArr
    get_save = gets.chomp.to_i
  end
  get_file_str = fileArr[get_save - 1]
  get_file_str = get_file_str[2..20]
  save_information = File.read("../hangman/save_games/#{get_file_str}")
  save_information = JSON.parse(save_information)
  save_information
end

user_input = ''

puts 'Do you want to load a game? (y/n)'
load_check = gets.chomp

new_game_start = true

if load_check == 'y'
  save_choice = load_game
  if save_choice.nil?
    puts 'There are no save files to load.'
  else
    new_game_start = false
    new_game = Hangman.new
    new_game.load_up(save_choice[0], save_choice[1], save_choice[2])
    new_game.main_screen
  end
end

if new_game_start == true
  new_game = Hangman.new
  new_game.fresh_start
  new_game.player_name
end

endgame = false

until new_game.win_condition == true || endgame == true
  new_game.main_screen
  puts 'Guess a letter...'
  puts new_game.win_condition
  user_input = gets.chomp.downcase.to_s.strip until user_input == 'save' || user_input == 'exit' || user_input.size == 1
  if user_input == 'save'
    SaveGame.new(new_game)
  elsif user_input == 'exit'
    endgame = true
  else
    new_game.play_turn(user_input)
  end
  user_input = ''
end

puts new_game.end_game
