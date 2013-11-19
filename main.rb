require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do
	def card_value(card_array)
  	new_array = card_array.map{|x| x[1]}
  	total = 0
 	  first_ace = 'true'
  	new_array.each do |value|
			if value == "A"
	  		if first_ace
	  			if (total < 11)
	     	 	total += 11
	    		else
	      		total += 1
	    		end
	    		first_ace = 'false'
	  		else
	    		total += 1
	  		end
			elsif value.to_i == 0
	  		total += 10
			else
	  		total += value.to_i
			end
  	end
  	total
	end

	def card_image(card)
		suit = case card[0]
			when 'H' then 'hearts'
			when 'D' then 'diamonds'
			when 'S' then 'spades'
			when 'C' then 'clubs'
		end

		value = card[1]
		if ['J', 'Q', 'K', 'A'].include?(value)
			value = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end
		end

		"<img src='/images/cards/#{suit}_#{value}.jpg'>"
	end
end

def win
	@play_again = true
	@show_hit_or_stay_buttons = false
	@success = "#{session[:player_name]} wins!"
end

def lose
	@play_again = true
	@show_hit_or_stay_buttons = false
	@success = "#{session[:player_name]} loses!"
	erb :game
end

def tie
	@play_again = true
	@show_hit_or_stay_buttons = false
	@success = "It's a tie!"
end



before do
	@show_hit_or_stay_buttons = true
end

get '/' do
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
	if params[:player_name].empty?
		@error = "You must enter your name"
		halt erb(:new_player)
	end

	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do

	values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  suits = ['H', 'D', 'S', 'C']
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  session[:turn] = "player"
	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop
	if card_value(session[:player_cards]) == 21
		win
	elsif card_value(session[:player_cards]) > 21
		@play_again = true
		lose	
	end
	erb :game
end

post '/game/player/stay' do
	@success = "You have chosen to stay"
	@show_hit_or_stay_buttons = false
	redirect '/game/dealer'
end

get '/game/dealer' do
	session["turn"] = "dealer"
	@show_dealer_hit = false
	dealer_total = card_value(session[:dealer_cards])

	if dealer_total == 21
			lose
	elsif dealer_total >21
		win
	elsif dealer_total >= 17
		redirect '/game/compare'
	else
		@show_dealer_hit = true
	end

	erb :game
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect 'game/dealer'
end

get '/game/compare' do
	@show_hit_or_stay_buttons = false

	player_total = card_value(session[:player_cards])
  dealer_total = card_value(session[:dealer_cards])

  if player_total < dealer_total
    lose
  elsif player_total > dealer_total
    win
  else
    tie
  end
  erb :game
end

get '/game_over' do
	erb :game_over
end