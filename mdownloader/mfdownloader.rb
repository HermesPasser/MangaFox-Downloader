require_relative 'mdownloader'
require 'net/http'
require 'open-uri'
require 'thread'

module MDownloader
	class Mangafox < MangaDownloader
		
		def initialize(path, manga, vol, chapter)
			super(path, manga, vol, chapter)
			@domain = "mangafox.me"
		end
		
		def get_cover
			html = Net::HTTP.get(@domain, "/manga/#{@manga_name}/").gsub("<meta property=\"og:image\" content=\"", "~%#").gsub("\" />", "~").split("~")
			html.each { |line| if line.include?("%#") then return line.gsub("%#", "") end}
		end

		# Get the number of pages of the manga
		def get_total_pages(page)
			source = getHtml(page).split(";")
			total_pages = 0 
			source.each do |pos|
				if pos.include? "total_pages" 
					return pos[pos.index("=") + 1, pos.length].to_i 
				end
			end
		end

		# Cria um vetor com os endereços das pgs
		def get_page_links(domain_page)
			total_pages = get_total_pages(domain_page)
			pages = []
			for current in 1..total_pages
				pages << "#{domain_page}#{current}.html" 
			end
			return pages
		end

		# Get the image link
		def get_image_link(page)
			source = getHtml(page)
			source = source.gsub("enlarge()", "º")
			source = source[source.index("º"), source.length]
			source = source.gsub("http://", "$")
			source = source[source.index("$"), source.length]
			return source[1, source.index("\"") - 1]
		end

		# Download all chapters of the manga
		def download_chapter
			@manga_volume == "" ? vol = "" : vol = "/" + @manga_volume
			webpages = get_page_links("/manga/#{@manga_name}#{vol}/#{@manga_chapter}/")
			threads = []
			i = 1
			
			webpages.each do |wp| 
				imagelink = get_image_link(wp)
				threads << Thread.new{
					download_image(imagelink, "#{@manga_name}_#{@manga_volume}_#{@manga_chapter}_#{i.to_s}")
					print($LOG += "\nDownloaded: #{imagelink} in #{@path_to_download}\\#{@page_name}")
				}
				i += 1
			end
			
			threads.each(&:join)
			print($LOG += "\nDownload complete.")
		end	
	end
end