
# Filename: wunderground_example.rb
#
# Sample code to get weather data as JSON string and print as a tree.
#
# See also:
#  - http://www.wunderground.com/weather/api/d/docs?d=resources/code-samples&MR=1
#  - http://rubytree.rubyforge.org/rdoc/#label-DOCUMENTATION

require 'open-uri'
require 'json'
require 'yaml'

## usage:
# ruby wunderground_example.rb 0123456789abcdef 0 12345
# ruby wunderground_example.rb 0123456789abcdef 1 FL Some_City

## params:

my_key= ARGV[0] # '0123456789abcdef' # replace with your 16 hex digit api key code; get one at "http://www.wunderground.com/weather/api/d/login.html"

by_city=ARGV[1].to_i # 1 # 0 or 1
by_city = 0 unless ([0,1].include?(by_city))
by_zip=(1-by_city)

if (by_city==1)
  wu_command='conditions'
  wu_state=ARGV[2] # 'AB' # your target state
  wu_city=ARGV[3] # 'Some_Place' # your target city, replacing spaces with "_"
  wu_url="http://api.wunderground.com/api/#{my_key}/geolookup/#{wu_command}/q/#{wu_state}/#{wu_city}.json"
end

if(by_zip==1)
  wu_zip=ARGV[2] # '01234' # your target zip
  wu_url="http://api.wunderground.com/api/#{my_key}/geolookup/q/#{wu_zip}.json"

  pollen_url="http://www.claritin.com/weatherpollenservice/weatherpollenservice.svc/getforecast/#{wu_zip}"
end

## main code:

def puts_tree(level,json_nodes,indent_chars = '  ', prefix_chars = '- ')
  unless (json_nodes.respond_to?('keys'))
    puts "#{indent_chars * level}#{prefix_chars}#{json_nodes}"
  else
    ks = json_nodes.keys
    ks.each do |k|
      puts "#{indent_chars * level}#{prefix_chars}#{k}:"
      v=json_nodes[k]
      if v.is_a? Hash
        puts_tree(level + 1,v,indent_chars,prefix_chars)
      else if v.is_a? Array
        v.each do |a|
          puts_tree(level + 1,a,indent_chars,prefix_chars)
        end    
        v.each_index do |i|
          a = v[i]
          puts "#{indent_chars * (level + 1)}#{prefix_chars}#{i}"
          puts_tree(level + 2,a,indent_chars,prefix_chars)
        end    
      else
        # puts "#{indent_chars * level}#{prefix_chars}#{k}: #{v}"
        puts "#{indent_chars * (level + 1)}#{prefix_chars}#{v}"
      end
      end
      
    end  
  end
end

# puts
# puts wu_url

open(wu_url) do |f|
  json_string = f.read
  parsed_json = JSON.parse(json_string)
  
  # location = parsed_json['location']['city']
  # temp_f = parsed_json['current_observation']['temp_f']
  # print "Current temperature in #{location} is: #{temp_f}\n"

  puts
  puts parsed_json.keys.join(',')

  puts
  puts_tree(0,parsed_json, indent_chars = '  ', prefix_chars = '- ')
end

if(by_zip==1)
  open(pollen_url) do |f|
    json_string = eval(f.read)
    
    # puts "[#{json_string.class}]"
    # puts "[#{json_string}]"
    # puts "[#{json_string[0]}]"
    
    # json_string = YAML.load(f.read)
    parsed_json = JSON.parse(json_string)
    # parsed_json = JSON.parse(eval(json_string).to_json) # 
    # puts "[#{parsed_json.class}]"
    # puts "[#{parsed_json}]"
    
    # location = parsed_json['location']['city']
    # temp_f = parsed_json['current_observation']['temp_f']
    # print "Current temperature in #{location} is: #{temp_f}\n"

    puts
    puts parsed_json.keys.join(',')

    puts
    puts_tree(0,parsed_json, indent_chars = '  ', prefix_chars = '- ')
  end
end
