require './app.rb'
require 'telegram/bot'
require 'securerandom'

token = ENV['APPETITE_TELEGRAM_TOKEN']
restaurants = ENDPOINTS.keys

WELCOME_MSG = "Hi there!
Write my username and select the restaurant you want.
Created with <3 by @javierhonduco"

def stringify(result)
  result * "\n"
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      results = restaurants.map do |rest|
        inline = Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: SecureRandom.uuid,
          title: rest,
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
            message_text: "Menu @#{rest}:\n#{stringify(get_menu(rest))}"
          )
        )
      end

      bot.api.answer_inline_query(
        inline_query_id: message.id,
        results: results,
        cache_time: 0
      )
    when Telegram::Bot::Types::Message
      case message.text
        when '/start'
          bot.api.send_message(chat_id: message.chat.id, text: WELCOME_MSG)
        when '/help'
          bot.api.send_message(chat_id: message.chat.id, text: "I need somebody!")
        when /^\/track (?<word>[a-z]+)/
          bot.api.send_message(chat_id: message.chat.id, text: "word: #{$1}")
      end
    end
  end
end
