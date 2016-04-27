require './app.rb'
require 'telegram/bot'

token = ENV['APPETITE_TELEGRAM_TOKEN']
restaurants = ENDPOINTS.keys

Telegram::Bot::Client.run(token) do |tg|
  tg.api.send_message(chat_id: ARGV.first.to_i, text: 'hi!')
end
