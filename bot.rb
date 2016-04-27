require './app.rb'
require 'telegram/bot'

token = ENV['APPETITE_TELEGRAM_TOKEN']
restaurants = ENDPOINTS.keys

def stringify result
  result * "\n"
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      results = restaurants.map do |rest|
        Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: rand(0..999999999999),
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
      bot.api.send_message(chat_id: message.chat.id, text: 'Hello there!')
    end
  end
end
