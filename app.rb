require 'httparty'
require 'nokogiri'

def formatted_time(t = Time.now)
  [t.day, t.month, t.year]
end

def perform_get(url)
  HTTParty.get(url, timeout: 10)
end

ENDPOINTS = {
  taffa: 'https://www.teknologforeningen.fi/?lang=en',
  alvari: 'http://www.amica.fi/modules/json/json/Index?costNumber=0190&language=en',
  tuas: 'http://www.amica.fi/modules/json/json/Index?costNumber=0199&language=en',
  cs: 'http://www.sodexo.fi/ruokalistat/output/daily_json/142/%d/%d/%d/fi',
  valimo: 'http://www.sodexo.fi/ruokalistat/output/daily_json/13918/%d/%d/%d/fi'
}

STRATEGIES = {
  cs: :sodexo_json,
  valimo: :sodexo_json,
  tuas: :amica_parsing,
  alvari: :amica_parsing,
  taffa: :taffa_parsing
}

def parse_taffa(url)
  response = perform_get url
  parsed = Nokogiri.parse response
  parsed.css('.todays-menu > ul > li').map { |dish|
    dish.text
  }
end

def parse_sodexo(url)
  response = perform_get url
  response['courses'].map { |course|
    course['title_en']
  }
end

def parse_amica(url)
  response = perform_get url
  response['MenusForDays'].first['SetMenus'].map { |menu|
    menu['Components']
  }
end

def get_menu(cafe)
  cafe = cafe.to_sym
  endpoint = ENDPOINTS[cafe]
  case STRATEGIES[cafe]
  when :sodexo_json
    parse_sodexo endpoint % formatted_time
  when :amica_parsing
    parse_amica endpoint
  when :taffa_parsing
    parse_taffa endpoint
  end
end
