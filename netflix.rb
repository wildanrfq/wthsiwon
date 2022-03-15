# wthsiwon (WHAT THE HELL SHOULD I WATCH ON NETFLIX) by danrfq

require "open-uri"
require "nokogiri"

NUMS = (1..170).to_a
NUMS.delete(166)

BASE_URL = "http://whatthehellshouldiwatchonnetflix.com/page/{num}/?random=2" # yes it's not an HTTPS URL
NUM = NUMS.sample.to_s

result = URI.open(BASE_URL.gsub! "{num}", NUM)
data = Nokogiri::HTML(result)

title = data.css("main h1").first.content
clean_title = title.split(" (")[0]
rating = data.css("strong").first.content[1..-1].delete_suffix!("]")
trailer = data.css("main iframe").first.attributes["src"].value.split("?")[0].gsub! "embed/", "watch/?v="
info = data.css("main p")[2..-1][0..-6]
netflix = data.css("main a").map {_1.attributes['href'].value }.find { _1.include?('trackId')}

if info.length == 1
    synopsis = info.first

    if !synopsis
        puts "There's an unexpected error while parsing the information. Trying again..." # can't be handled due to inconsistent data structure, sorry
        exec("ruby #{__FILE__}")
    end

    synopsis = synopsis.content.split("[")[0].gsub "\n", ""
    review = nil
else
    synopsis = info.first

    if !synopsis
        puts "There's an unexpected error while parsing the information. Trying again..." # can't be handled due to inconsistent data structure, sorry
        exec("ruby #{__FILE__}")
    end

    synopsis = synopsis.content.split("[")[0].gsub "\n", ""
    review = info[1].content
end

if !info.last
    puts "There's an unexpected error while parsing the information. Trying again..." # can't be handled due to inconsistent data structure, sorry
    exec("ruby #{__FILE__}")
end

if info.last.content.start_with?("Or")
    rotten_tomatoes = info[-2].content
    rotten_tomatoes_link = info[-2].css("a").first.attributes["href"].value
elsif info.last.content.include?("Rotten Tomatoes")
    rotten_tomatoes = info.last.content
    rotten_tomatoes_link = info.last.css("a").first.attributes["href"].value
else
    rotten_tomatoes = nil
    rotten_tomatoes_link = nil
end

puts "wthsiwon (WHAT THE HELL SHOULD I WATCH ON NETFLIX?)\n\n"

puts "Title: #{title}"

rating ? puts("Rating: #{rating}\n") : puts("Rating: -")

rotten_tomatoes ? puts("#{rotten_tomatoes} (#{rotten_tomatoes_link})\n") : puts()

puts "Synopsis: #{synopsis}\n\n"

review ? puts("Review: #{review}\n\n") : puts("Review: -\n\n")

puts "Watch #{clean_title} trailer on YouTube: #{trailer}\n\n"

puts "Watch #{clean_title} in Netflix: #{netflix}"