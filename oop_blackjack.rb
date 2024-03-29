# is a relationship => inheritance
# ex. class Dog < Animal

#has a relationship => Composition
# modual Swimmable
# class Dog
# include Swimmable
class Card
  attr_accessor :suit, :value

  def initialize(s, v)
    @suit = s
    @value = v
  end

  def pretty_output
    "The #{value} of #{find_suit}"
  end

  def find_suit
    ret_val = case suit
                when 'H' then 'Hearts'
                when 'D' then 'Diamonds'
                when 'S' then 'Spades'
                when 'C' then 'Clubs'
              end
    ret_val
  end

  def to_s
    pretty_output
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['H', 'D', 'S', 'C'].each do |suit|
      ['2', '3', '4', '5', '6', '7','8', '9', '10', 'J', 'Q', 'K', 'A'].each do |value|
        @cards << Card.new(suit, value)
      end
    end
    scramble!
  end

  def scramble!
    cards.shuffle!
  end

  def deal_one
    cards.pop
  end

  def size
    cards.size
  end
end

module Hand
  def show_hand
    puts "----- #{name}'s Hand -----'"
    cards.each do|card|
      puts "=> #{card}"
    end
    puts "=> Total: #{total}"
  end

  def total
    values = cards.map{|card| card.value }

    total = 0
    values.each do |val|
      if val == "A"
        total += 11
      else
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end

    #correct for Aces
    values.select{|val| val == "A"}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def add_card(new_card)
    cards << new_card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end
end

class Player
  include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n
    @cards = []
  end

  def show_flop
    show_hand
  end

end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"
    @cards = []
  end

  def show_flop
    puts "----- Dealer's Hand -----"
    puts "=> First card is hidden"
    puts "=> Second card is #{cards[1]}"
  end
end



class Blackjack
  attr_accessor :player, :dealer, :deck

  BLACKJACK_AMOUNT = 21
  DEALER_HIT_MIN = 17

  def initialize
    @deck = Deck.new
    @player = Player.new("Player_1")
    @dealer = Dealer.new
  end

  def set_player_name
    puts "What's your name?"
    player.name = gets.chomp
  end

  def deal_cards
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
    player.add_card(deck.deal_one)
    dealer.add_card(deck.deal_one)
  end

  def show_hands
    player.show_flop
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)
        puts "Sorry, dealer hit blackjack. #{player.name} loses."
      else
        puts "Congratulations, you hit blackjack! You win!"
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted. #{player.name} wins!"
      else
        puts "Sorry, #{player.name} busted. #{player.name} loses."
      end
      play_again?
    end
  end

  def player_turn
    puts "#{player.name}'s turn."

    blackjack_or_bust?(player)

    while !player.is_busted?
      puts "What would you like to do? 1) hit 2) stay"
      response = gets.chomp

      if !['1', '2'].include?(response)
        puts "Error: You must enter 1 or 2"
        next
      end

      if response == '2'
        puts "#{player.name} chose to stay."
        break
      end

      #hit
      new_card = deck.deal_one
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now : #{player.total}"

      blackjack_or_bust?(player)
    end
    puts "#{player.name} stays."
  end

  def dealer_turn
    puts "Dealer's turn."

    blackjack_or_bust?(dealer)
    while dealer.total < DEALER_HIT_MIN
      new_card = deck.deal_one
      puts "Dealing card to dealer: #{new_card}"
      dealer.add_card(new_card)
      puts "Dealer total is now: #{dealer.total}"

      blackjack_or_bust?(dealer)
    end
    puts "Dealer stays at #{dealer.total}."
  end

  def who_won?
    if player.total > dealer.total
      puts "Congratulations, #{player.name} wins!"
    elsif player.total < dealer.total
      puts "Sorry, #{player.name} loses."
    else
      puts "It's a tie!"
    end
    play_again?
  end

  def play_again?
    puts ""
    puts "Would you like to play again? 1) yes 2) no, exit"
    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      run
    else
      puts "Goodbye!"
      exit
    end
  end

  def run
    set_player_name
    deal_cards
    show_hands
    player_turn
    dealer_turn
    who_won?
  end

end

game = Blackjack.new
game.run

#deck = Deck.new
#player = Player.new("Chris")
#player.add_card(deck.deal_one)
#player.add_card(deck.deal_one)
#player.add_card(deck.deal_one)
#player.add_card(deck.deal_one)
#player.show_hand
#
#
#dealer = Dealer.new
#dealer.add_card(deck.deal_one)
#dealer.add_card(deck.deal_one)
#dealer.add_card(deck.deal_one)
#dealer.add_card(deck.deal_one)
#dealer.show_hand
