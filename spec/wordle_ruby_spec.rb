# frozen_string_literal: true

RSpec.describe WordleRuby do
  # it 'has a version number' do
  #   expect(WordleRuby.word_weight('aegis', WordleRuby::Words::LIST)).to eq(7889)
  # end

  # it "heaviest word" do
  #   expect(WordleRuby.heaviest_word(WordleRuby::Words::LIST)).to eq(7889)
  # end

  it 'server response' do
    response = WordleRuby.server_response('aegis', 'boats')
    result = [['a', :yellow], ['e', :black], ['g', :black], ['i', :black], ['s', :green]]
    expect(response).to eq(result)
  end

  it 'server response' do
    state = WordleRuby::GameState.new

    result = [['a', :black], ['e', :black], ['g', :black], ['i', :black], ['s', :black]]
    state.record_response(result)
    expect(state.next).to eq('test')
  end

  # it 'play watch' do
  #   WordleRuby.play('watch')
  # end

  it 'test game' do
    state = WordleRuby::GameState.new
    state.record_response(WordleRuby.server_response('arose', 'boats'))
    state.record_response(WordleRuby.server_response('coals', 'boats'))
    state.record_response(WordleRuby.server_response('moats', 'boats'))

    expect(state.next).to eq('boats')
  end

  it 'game loop' do
    success_count = 0
    fail_count = 0

    WordleRuby::Words::LIST.each do |list_word|
      state = WordleRuby::GameState.new

      guess_count = 0
      guesses = []
      while guess_count < 6
        if state.next == list_word
          pp "Found in #{guess_count + 1} tries: #{list_word} | #{guesses}"
          success_count += 1
          break
        end

        guesses << state.next
        state.record_response(WordleRuby.server_response(state.next, list_word))
        guess_count += 1
      end

      if guess_count == 6
        pp "Failed: #{list_word} | #{guesses} : Next: #{state.next}"
        fail_count += 1
      end
    end

    pp "Success: #{success_count}, Fail: #{fail_count}, Fail Rate: #{fail_count.to_f / (fail_count + success_count)}"
  end

  # it 'state' do
  #   state = WordleRuby::GameState.new
  #
  #   state.record_response([['a', :yellow], ['e', :black], ['g', :black], ['i', :black], ['s', :green]])
  #
  #   count = 0
  #   state.potential_words.each do |word|
  #     pp word
  #     count += 1
  #   end
  #
  #   words = state.potential_words.to_a
  #   guess = WordleRuby.heaviest_word(words)
  #
  #
  #   expect(guess).to be(4594)
  # end
end
