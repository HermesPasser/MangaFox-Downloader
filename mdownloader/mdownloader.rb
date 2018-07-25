# (ver.3) Base class for all manga downloader
require 'open-uri'
require 'net/http'
 
module MDownloader
    class MangaDownloader
        attr_reader   :domain
        attr_accessor :path_to_download, :manga_name, :manga_volume, :manga_chapter
         
        def initialize(path, manga, vol, chapter)
            @path_to_download = path
            @manga_name       = manga
            @manga_volume     = vol
            @manga_chapter    = chapter
            @domain           = ""
        end
     
        def self.url_page_exits?(domain, page)
		    begin
				return Net::HTTP.get(domain, page) != ""
			rescue Errno::ECONNREFUSED
				puts 'MDownloader::MangaDownloader: Errno::ECONNREFUSED: Failed to open TCP connection to :80'
				return nil
            end
        end
         
        def getHtml(page)
            begin
                retries ||= 0
                # It receives a vector that in each position has a line of the html document
                return Net::HTTP.get(@domain, page)
            rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
                if (retries += 1) < 3 then retry
                else return false;
                end
            end
        end
         
        def download_image(url, page_name)
            File.open("#{@path_to_download}\\#{page_name}.jpg", 'wb') do |f|
                f.write open("http://#{url}").read
            end
        end
    end
end