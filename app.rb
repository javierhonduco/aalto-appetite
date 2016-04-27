require 'httparty'
require 'nokogiri'

ENDPOINTS = {
  :taffa => 'https://www.teknologforeningen.fi/?lang=en',
  :alvari => 'http://www.amica.fi/modules/json/json/Index?costNumber=0190&language=en',
  :tuas => 'http://www.amica.fi/modules/json/json/Index?costNumber=0199&language=en',
  :cs => 'http://www.sodexo.fi/ruokalistat/output/daily_json/142/2016/04/26/fi',
  :valimo => 'http://www.sodexo.fi/ruokalistat/output/daily_json/13918/2016/04/26/fi'
}

STRATEGIES = {
  :cs => :sodexo_json,
  :valimo => :sodexo_json,
  :tuas => :amica_parsing,
  :alvari => :amica_parsing,
  :taffa => :taffa_parsing
}

def parse_taffa url
  response = HTTParty.get(url)
  parsed = Nokogiri.parse(response)
  parsed.css('.todays-menu > ul > li').map {|dish|
    dish.text
  }
end

def parse_sodexo url
  response = HTTParty.get(url)
  response['courses'].map { |course|
    course['title_en']
  }
end

def parse_amica url
  response = HTTParty.get(url)
  response['MenusForDays'].first['SetMenus'].map { |menu|
    menu['Components']
  }
end

def get_menu cafe
  cafe = cafe.to_sym
  endpoint = ENDPOINTS[cafe]
  case STRATEGIES[cafe]
    when :sodexo_json
      parse_sodexo(endpoint)
    when :amica_parsing
      parse_amica(endpoint)
    when :taffa_parsing
      parse_taffa(endpoint)
  end
end
