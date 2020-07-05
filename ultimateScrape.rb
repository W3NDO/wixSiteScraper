require 'mechanize'
require 'nokogiri'
require 'json'
require 'open-uri'
require 'colorize'

article = Hash.new #holds the article title, body and all associated image links

agent = Mechanize.new
page1 = agent.get('https://jumachris3.wixsite.com/ultimate-gc/blog') #The wix site I was scraping
page2 = agent.get('https://jumachris3.wixsite.com/ultimate-gc/blog/page/1') #page 2 of the wix site

pages = [page2, page1] #array of pages to go through

def getArticleLinks(arr) #Gets the links of the articles to be visited
	links =[]
	puts "getting article links"
	for i in 0..arr.length()-1
		arr[i].css('a span').each do |link|
			if link.text.strip == "Read More"
				puts "...".blue
				links << link.parent.parent.parent.parent["href"]
			end
		end
	end
	puts "Got #{links.length()} Links".yellow
	return links
end

def getArticleTitles(arr) #Gets the titles of the articles
	titles = []
	puts "Getting Article titles".blue
	for i in 0..arr.length()-1
		arr[i].css('h2').each do |title|
			puts "...".blue
			titles << title.text.strip
		end
	end
	puts "got #{titles.length} Titles".yellow
	return titles
end

def getImageSrc(arrayOfLinks) #Gets the src of the images for each article
	srcCount = 0 #counts number of links got
	articleNumber = 0 
	agent = Mechanize.new
	imageSrc = Hash.new

	for i in 0..arrayOfLinks.length()-1
		articleNumber += 1
		regex = /(inner)?comp./ 
		artArr = []
		puts "Getting image sources for article #{articleNumber}".yellow
		articleImgSrcArr = []
		entry = agent.get(arrayOfLinks[i])
		srcArr = entry.search('img') #get's every image on the page
		
		srcArr.each do |img|
			srcCount +=1

			if img["src"] == nil
				next
			elsif regex.match? img["id"] #Gets the src of any image with ...comp... in the id
				artArr << img["src"] #Puts the links in an array
			end
		
		end
		imageSrc[articleNumber] = artArr #puts the link array in a hash
	end

	puts "Got #{srcCount} Links".yellow
	return imageSrc
end

#TBD
def getArticleText()

end

#This is what I need to work on
def downloadImages(linkHash)
	pwd = Dir.pwd
	imgCount = 0
	linkHash.each do |key, value|
		puts "Making Directory #{key}".yellow
		dirName = key.to_s
		Dir.mkdir(dirName) unless File.exists?(dirName) #make a directory with the Key 

		value.each do |img|
			imgCount += 1
			puts "Downloading from #{img}".blue
			open(img) do |image|
				File.open("#{pwd}/#{dirName}/#{imgCount.to_s}", "w") do |file|
					file.write(image.read)
					file.close
				end
			end
		end
		system ("cd ..")
	end
end

links = getArticleLinks(pages)
titles = getArticleTitles(pages)
imageSrc = getImageSrc(links)
imageSource = JSON.pretty_generate(imageSrc) #creates a formatted JSON doc
content = File.open('imageSource.json', 'w') #creates a JSON file
content.write(imageSource) #Writes the Json file
content.close
#system("vim imageSource.json")
downloadImages(imageSrc) #downloads the images
puts "Scrape DONE".green
#add a progress bar
