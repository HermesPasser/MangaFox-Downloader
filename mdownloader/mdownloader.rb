# Base class for all manga downloader
require 'open-uri'
require 'net/http'

module MDownloader
	class MangaDownloader
		attr_reader   :domain
		attr_accessor :path_to_download, :manga_name, :manga_volume, :manga_chapter
		
		def initialize(path, manga, vol, chapter)
			@path_to_download = path
			@manga_name		  = manga
			@manga_volume	  = vol
			@manga_chapter	  = chapter
			@domain			  = ""
		end
	
		def self.url_page_exits?(domain, page)
			Net::HTTP.get(domain, page) != ""
		end

		def download_image(url, page_name)
			File.open("C:\\Users\\Diogo\\Desktop\\" + page_name + ".jpg", 'wb') do |f|
				f.write open("http://#{url}").read
			end
		end
	end
end