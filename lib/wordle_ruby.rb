# frozen_string_literal: true

require_relative 'wordle_ruby/version'
require_relative 'wordle_ruby/words'
require_relative 'wordle_ruby/game_state'

module WordleRuby
  class Error < StandardError; end

  def self.letter_histogram(words)
    histogram = Hash.new(0)
    words.each do |word|
      word.each_char.uniq.each { |letter| histogram[letter] = histogram[letter] + 1 }
    end

    histogram
  end

  def self.word_weight(word, histogram)
    word.each_char.uniq.reduce(0) do |acc, letter|
      acc + (histogram[letter] || 0)
    end
  end

  def self.heaviest_word(words)
    histogram = letter_histogram(words)
    winning_word = nil
    winning_weight = nil

    words.each do |word|
      if winning_word.nil?
        winning_word = word
        winning_weight = word_weight(word, histogram)
        next
      end

      cur_weight = word_weight(word, histogram)
      if cur_weight > winning_weight
        winning_word = word
        winning_weight = cur_weight
      end
    end

    winning_word
  end

  def self.server_response(guess, word)
    response = []
    guess.each_char.with_index do |letter, index|
      next response << [letter, :green] if letter == word[index]
      next response << [letter, :black] if word.index(letter).nil?

      response << [letter, :yellow]
    end

    response
  end

  def self.play(word)
    state = WordleRuby::GameState.new

    guess_count = 0
    guesses = []
    while guess_count < 6
      if state.next == word
        pp "Found in #{guess_count + 1} tries: #{word} | #{guesses}"
        break
      end

      guesses << state.next
      state.record_response(WordleRuby.server_response(state.next, word))
      guess_count += 1
    end

    if guess_count == 6
      pp "Failed: #{word} | #{guesses} : Next: #{state.next}"
    end
  end
end
