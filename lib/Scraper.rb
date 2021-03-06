require 'open-uri'
require 'nokogiri'
require 'json'
require 'twitter'
require 'twitter-text'

#Base class for all the scraping class
class Scraper
   attr_accessor :url, :location

   def initialize(name)
   	@location = name
   end

  def scrapeUrl(url)
  	doc = Nokogiri::HTML(open(url))
  	return doc
  end

  def scrapeObj(url)
  	doc = Nokogiri::XML(url)
  	return doc
  end
end

=begin

obj = FlickrScraper.new(CountryName)
obj.getImageUrl() <- it returns the url of the image at original size

=end

class FlickrScraper < Scraper
	def getImageUrl()
		string = ""
		response = open('https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=506ed830c6237fa6d09a78faf55611ff&privacy_filter=1&safe_search=1&content_type=1&tags='+location+'&per_page=100&page=1&extras=original_format&format=rest').read
		doc = scrapeObj(response)
		res = doc.xpath("//photo")
		res.each do |rs|
			id = rs[:id]
			puts "id is #{id}"
			sizeGET = open('https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=506ed830c6237fa6d09a78faf55611ff&&photo_id='+id+'&format=rest')
			docSize = scrapeObj(sizeGET)
			docSizePath = docSize.xpath("//size")
			puts docSizePath.count
			docSizePath.each do |dsp|
				if(dsp[:label] == 'Original')
					string = dsp[:source]
					puts "string is #{string}"
					return string
				end
			end
		end
		puts "Image not found"
		return 1
	end
end


class NewsScraper < Scraper
	def getNews()
		doc = scrapeUrl("http://www.faroo.com/api?q=#{location}&start=1&length=5&l=en&src=news&f=xml&key=lBbetYupJAk2n8scJmiKTVDlNrw_")
		return doc
	end
    
	def getCapital()
		doc = scrapeUrl("http://en.wikipedia.org/wiki/"+location)
		#print(doc)
		doc.xpath("//Infobox") do |node|
			print(node)
		end
	end
end

=begin

	obj = TwitterScraper.new(CountryName)
    obj.getTrends() <- it returns an array of trends objects, iterate it and parse the name attribute.

    obj.getTreands().each do |tr| 
    	tr.name
	end

=end
class TwitterScraper < Scraper
	include Twitter::Autolink
	attr_accessor :client

	def initialize(name)
		@location = name
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key        = "g5ofKtyrzpeqiWHUAzkWo1v29"
			config.consumer_secret     = "YKSQEyBYfgUxB1ngq9sebyjBafg9soHTtd1pb3HLpknQFV164l"
			config.access_token        = "39591048-C2G2DYVox97585H9eO8eejEoVRpTMq1hrJmYcrcVd"
			config.access_token_secret = "mKzLzKcijbMyOYneU4yuejorR5Rmx7uCd1KyrZBory9SH"
		end
	end

	def parseJson()
		json = File.read(Rails::root+"lib/assets/trends_available.json")
		return JSON.parse(json)
	end

	def getTrends()
		puts "location is #{@location} , looking for WOEID"
		countryCode = ""
		locationAvailable = parseJson()
		locationAvailable.each do |loc|
			if(loc["name"].capitalize.to_s == @location.to_s)
				puts "found!"
				puts loc["name"]
				puts loc["woeid"]
				countryCode = loc["woeid"]
			end
		end
		puts "code is #{countryCode}"
		trends = client.trends(countryCode)
		trends.each do |tr|
			puts tr.name
		end
		return trends
	end
	
	def getTweets()
    puts "waiting on twitter"
    return @client.search(@location, :result_type => "recent").take(6).collect
	end

	def getCountryCode()
		res = []
		countries = parseJson()
		countries.each do |country|
			res << country["countryCode"]
		end
		return res
	end
end

class YouTubeScraper < Scraper
	attr_accessor :location

	def initialize(location)
		@location = location
	end
	def get_videos
		client = YouTubeIt::Client.new(dev_key: "AIzaSyBcY6x0hRCf1of_ARJzFyW47s5PGYCpS_Y")
		results = client.videos_by(:recently_featured, region: location)
	end
end
