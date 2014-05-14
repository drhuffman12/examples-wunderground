
# Filename: wunderground_example.rb
#
# Sample code to get weather data as JSON string and print as a tree.
#
# See also:
#  - http://www.wunderground.com/weather/api/d/docs?d=resources/code-samples&MR=1
#  - http://rubytree.rubyforge.org/rdoc/#label-DOCUMENTATION

require 'open-uri'
require 'json'

my_key='0123456789abcdef' # replace with your 16 hex digit api key code; get one at "http://www.wunderground.com/weather/api/d/login.html"

by_city=1 # 0 or 1
by_zip=(1-by_city)

if (by_city==1)
  wu_command='conditions'
  wu_state='AB' # your target state
  wu_city='Some_Place' # your target city, replacing spaces with "_"
  wu_url="http://api.wunderground.com/api/#{my_key}/geolookup/#{wu_command}/q/#{wu_state}/#{wu_city}.json"
end

if(by_zip==1)
  wu_zip='01234' # your target zip
  wu_url="http://api.wunderground.com/api/#{my_key}/geolookup/q/#{wu_zip}.json"
end


def puts_tree(level,json_nodes,indent_chars = '  ', prefix_chars = '- ')
  ks = json_nodes.keys
  ks.each do |k|
    v=json_nodes[k]
    if v.is_a? Hash
      puts_tree(level + 1,v,indent_chars,prefix_chars)
    else if v.is_a? Array
      v.each do |a|
        puts_tree(level + 1,a,indent_chars,prefix_chars)
      end      
    else
      puts "#{indent_chars * level}#{prefix_chars}#{k}: #{v}"
    end
    end
    
  end  
end

puts wu_url

open(wu_url) do |f|
  json_string = f.read
  parsed_json = JSON.parse(json_string)
  
  # location = parsed_json['location']['city']
  # temp_f = parsed_json['current_observation']['temp_f']
  # print "Current temperature in #{location} is: #{temp_f}\n"

  puts parsed_json.keys.join(',')
  
  puts_tree(0,parsed_json, indent_chars = '  ', prefix_chars = '- ')
end
