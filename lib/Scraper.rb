require 'open-uri'
require 'nokogiri'
require 'json'

#Base class for all the scraping class
#TODO: Refactor
class Scraper
   attr_accessor :url

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
	attr_accessor :location

	def initialize(name)
		@location = name
	end

	def getImageUrl()
		string = 0
		response = open('https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=506ed830c6237fa6d09a78faf55611ff&text='+location+'&per_page=1&page=100&extras=original_format&format=rest').read
		print(response)
		doc = scrapeObj(response)
		res = doc.xpath("//photo")
		res.each do |rs|
			if(rs[:originalsecret].class != nil)
				farm = rs[:farm]
				secret = rs[:originalsecret]
				server = rs[:server]
				id = rs[:id]
				string = "http://farm"+farm+".staticflickr.com/"+server+"/"+id+"_"+secret+"_o.jpg"
			end

		end
		return string
	end
end

#WIP
class WikiScraper < Scraper
	attr_accessor :location

	def initialize(name)
		@location = name
	end

	def getCapital()
		doc = scrapeUrl("http://en.wikipedia.org/wiki/"+location)
		#print(doc)
		doc.xpath("//Infobox") do |node|
			print(node)
			
		end
	end
end

#WIP
class WeatherScraper < Scraper
	attr_accessor :location

	def getCapitalWeather(location)
	end
end