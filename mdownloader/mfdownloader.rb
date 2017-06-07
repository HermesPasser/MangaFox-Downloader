require 'open-uri'
require 'net/http'
require 'fileutils'

module MDownloader
  class Mangafox < MangaDownloader
    
    def self.get_cover(manga_name)
      html = Net::HTTP.get("mangafox.me", "/manga/#{manga_name}/").gsub("<meta property=\"og:image\" content=\"", "~%#").gsub("\" />", "~").split("~")
      html.each do |line|
        if line.include?("%#") then return line.gsub("%#", "") end
      end
    end
    
    # Recomendável que o link não tenha a pag
    def self.get_total_pages(domain, page)
      begin
        retries ||= 0
        # It receives a vector that in each position has a line of the html document
        source = Net::HTTP.get(domain, page).split(";")
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
    def self.get_page_links(domain, page)
      total_pages = get_total_pages(domain, page)
      
      pages = []
      for current in 1..total_pages
        pages << "#{page}#{current}.html"
      end
      return pages
    end
    
    # Pega o link da imagem
    def self.get_image_link(domain, page)
      begin
        retries ||= 0
        # It receives a vector that in each position has a line of the html document
        source = Net::HTTP.get(domain, page)
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

    def self.download_chapter(page)
      FileUtils.mkdir_p("C:\\Users\\Diogo\\Desktop\\mangas\\") #abstrainr
      
      domain = "mangafox.me"      
      webpages = get_page_links(domain, page)
      
      i = 1
      webpages.each do |wp|
        link =  get_image_link(domain, wp)
        download_image(link, i.to_s)
        i += 1
      end
      
      #abstrair abaixo usando o original
      #não sei para onde vai a img e ele trava antes de mover
      #
      i = 0
      while i < arry.length
        begin
          degub 
          FileUtils.mv("#{i}.jpg", "C:\\Users\\Diogo\\Desktop\\mangas\\")
        rescue Exception => ee
        end
      i += 1
      end
    end
  end
end

#def rename_files(manga, chapter, arry)
  #FileUtils.mkdir_p("#{@directory}\\mangas\\#{manga}\\#{chapter}")

  #i = 0
  #while i < arry.length
#    begin
 #     File.rename(arry[i], "#{manga} c#{chapter} p#{arry[i]}")
  #    putslog("renomeando arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.")
  #  rescue Exception => e
   #   putslog "Não foi possivel renomear arquivo #{arry[i]} para #{manga} c#{chapter} p#{arry[i]}.\nErro #{e}".encode("UTF-8", "Windows-1252")
   # end
    
   # begin
   #   FileUtils.mv("#{manga} c#{chapter} p#{arry[i]}", "#{@directory}\\mangas\\#{manga}\\#{chapter}")
   #   putslog("movendo #{manga} c#{chapter} p#{arry[i]} para #{@directory}\\mangas\\#{manga}\\#{chapter}".encode("UTF-8", "Windows-1252"))
  #  rescue Exception => ee
  #    putslog "Não foi possivel  mover #{manga} c#{chapter} p#{arry[i]} para #{@directory}\\mangas\\#{manga}\\#{chapter}.\nErro #{ee}".encode("UTF-8", "Windows-1252")
 #   end
    
 #   i += 1
#  end
#end