require './app.rb'
require 'telegram/bot'

token = ENV['APPETITE_TELEGRAM_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::InlineQuery
      results = [
        [3, 'CS', get_menu('cs'.to_sym).to_s],
        [4, 'Alvari', get_menu('alvari'.to_sym).to_s]
      ].map do |arr|
        Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: arr.first,
          title: arr[1],
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: arr[2])
        )
      end

      bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    when Telegram::Bot::Types::Message
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}!")
    end
  end
end
