require 'open-uri'
require 'net/http'
require './mdownloader/mdownloader'

module MDownloader
	class Mangafox < MangaDownloader
		
		def initialize(path, manga, vol, chapter)
			super(path, manga, vol, chapter)
			@domain = "mangafox.me"
		end
		
		def get_cover
			html = Net::HTTP.get(@domain, "/manga/#{@manga_name}/").gsub("<meta property=\"og:image\" content=\"", "~%#").gsub("\" />", "~").split("~")
			html.each do |line|
				if line.include?("%#") then return line.gsub("%#", "") end
			end
		end

		# Recomendável que o link não tenha a pag
		def get_total_pages(page)
			begin
				retries ||= 0
				# It receives a vector that in each position has a line of the html document
				source = Net::HTTP.get(@domain, page).split(";")
			rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
				if (retries += 1) < 3 then retry
				else return -1;
				end
			end

			total_pages = 0 
			source.each do |pos|
			if pos.include? "total_pages" then return pos[pos.index("=") + 1, pos.length].to_i end
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

		# Pega o link da imagem
		def get_image_link(page)
			begin
				retries ||= 0
				# It receives a vector that in each position has a line of the html document
				source = Net::HTTP.get(@domain, page)
			rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
				if (retries += 1) < 3 then retry
				else return -1;
				end
			end

			source = source.gsub("enlarge()", "º")
			source = source[source.index("º"), source.length]
			source = source.gsub("http://", "$")
			source = source[source.index("$"), source.length]
			return source[1, source.index("\"") - 1]
		end

		#A magika acontece aqui
		def download_chapter
			@manga_volume == "" ? vol = "" : vol = "/" + @manga_volume
			webpages = get_page_links("/manga/#{@manga_name}#{vol}/#{@manga_chapter}/")

			i = 1
			webpages.each do |wp|
				link =  get_image_link(wp)
				download_image(link, "#{@manga_name}_#{@manga_volume}_#{@manga_chapter}_#{i.to_s}")
				i += 1
			end
		end	
	end
end