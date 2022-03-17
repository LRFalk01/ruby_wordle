# frozen_string_literal: true

module WordleRuby
  class GameState
    def initialize
      @black_list = Set.new
      @contains = {}
      @known = {}
      @word_list = Words::LIST
      @guesses = 0
    end

    def black_list(letter)
      @black_list |= [letter]
    end

    def contains(letter, index)
      set = @contains[letter]
      @contains[letter] = set = Set.new unless set

      set << index
      nil
    end

    def known(letter, index)
      set = @known[letter]
      @known[letter] = set = Set.new unless set

      set << index
      nil
    end

    def can_be(word)
      @contains.each do |letter, indexes|
        return false if word.index(letter).nil?
        return false if indexes.any? { |x| word[x] == letter }
      end

      @known.each do |letter, indexes|
        return false unless indexes.all? { |x| word[x] == letter }
      end

      word.each_char do |word_letter|
        return false if @black_list.include?(word_letter)
      end

      true
    end

    def record_response(response)
      @guesses += 1
      response.each.with_index do |(letter, status), index|
        next black_list(letter) if status == :black
        next contains(letter, index) if status == :yellow

        known(letter, index)
      end

      @next = nil
      @word_list = potential_words.to_a
      nil
    end

    def potential_words
      Enumerator.new do |yielder|
        @word_list.each do |potential_word|
          yielder << potential_word if can_be(potential_word)
        end
      end
    end

    def next
      if @next.nil? && @known.values.sum(&:size) > 2 && @word_list.size > 6 - @guesses && @guesses < 5
        known_letters = @known.keys + @contains.keys
        letters = @word_list.reduce([]) do |acc, current_word|
          acc | current_word.each_char.reduce([]) { |acc, letter| acc | ([letter] - known_letters) }
        end

        winning_weight = 0
        winning_word = nil
        histogram = letters.each_with_object({}) { |cur, acc| acc[cur] = 1 }
        WordleRuby::Words::LIST.each do |word|
          current_weight = WordleRuby.word_weight(word, histogram)
          next unless current_weight > winning_weight

          winning_weight = current_weight
          winning_word = word
        end

        pp "Hail Mary: #{winning_word}, #{letters}"
        return @next = winning_word if winning_weight > 1
      end

      @next ||= WordleRuby.heaviest_word(@word_list)
    end
  end
end
