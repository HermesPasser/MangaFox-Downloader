require 'open-uri'
require 'net/http'

module MDownloader
  class MangaDownloader
    def self.url_page_exits?(domain, page)
      Net::HTTP.get(domain, page) != ""
    end
    
    def self.download_image(url, page_name)
      File.open(page_name + ".jpg", 'wb') do |f|
        f.write open("http://#{url}").read 
      end
    end 
  end
end