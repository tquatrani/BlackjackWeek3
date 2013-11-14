require 'rubygems'
require 'sinatra'

set :sessions, true

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
	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	erb :game
end

post '/game' do
	session[:player_bank] = "500"
	session[:player_bet] = params[:player_bet]
	redirect '/deal'
end

get '/deal' do
	values = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
  suits = ['H', 'D', 'S', 'C']
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []

  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop


	erb :deal
end




