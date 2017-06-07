load "downlader.rb"
require 'thread'
include MDownloader

Shoes.app(:title => "Mangafox Downloader") do
  #Shoes.show_log
  
  flow do
    @@lst_arquivo = list_box :items => ["Arquivo", "Sair"], width: 90, height: 25, choose: "Arquivo" 
    @@lst_sobre = list_box :items => ["?", "Sobre"], width: 35, height: 25, choose: "?"
  end

  flow do
    stack :margin => 10, :width => 350 do  
      flow do
        para("Name \t") 
        @@edit_name = edit_line(width: 200) {edit_Change}
      end
      
      flow do
        para "\t\t"
        @@search_manga = button("Search manga", width: 200) {run_in_thread {search_manga_Click}}
      end
      
      flow do
        para("Vol \t\t")
        @@edit_volume = edit_line(state: "disabled", width: 35) {edit_Change}
        para("\tChapter\t")
        @@edit_chapter = edit_line(state: "disabled", width: 64) {edit_Change}
      end
      
      flow do
        para "\t\t"
        @@download = button("Download", state: "disabled", width: 200) {run_in_thread {download_Click}}
      end
    end
    
    stack :margin => 10, :width => -350 do
      @@manga_thumb = image("cover.png")
      @@thum_alt = para("No loaded manga")
    end
  end

  every 1 do
    # Reset list box selected option
    @@lst_arquivo.choose("Arquivo")
    @@lst_sobre.choose("?")
  end
  
  def run_in_thread
    threads = []
    threads << Thread.new{yield}
  end
  
  def interface_status(state)
    @@edit_name.state = @@edit_volume.state = @@edit_chapter.state = @@search_manga.state = @@download.state = state
  end

  def clear_search
    interface_status(false)
    @@manga_thumb.path = "cover.png"
    @@thum_alt.text = "No loaded manga"
    @@edit_name.state = @@search_manga.state = nil
  end
  
  def edit_Change
     @@edit_name.text = @@edit_name.text.gsub(" ", "_").downcase
  end
  
  def search_manga_Click
    if @@edit_name.text == ""
      clear_search
      return
    end
    
    @@thum_alt.text = "Loading..."
    @@edit_name.state = @@search_manga.state = @@edit_volume.state = @@download.state = "disabled"
    
    if MDownloader::Mangafox::url_page_exits?("mangafox.me", "/manga/#{@@edit_name.text}/")
      link = MDownloader::Mangafox::get_cover(@@edit_name.text)
      @@manga_thumb.path = link
      @@thum_alt.text = @@edit_name.text.gsub("_", " ")
      @@edit_chapter.state = @@search_manga.state = @@edit_volume.state = @@download.state = @@edit_name.state = nil
    else 
      #alert("Cannot find the manga.")
      clear_search
    end
  end
  
  def download_Click
    interface_status("disabled")
    @@edit_volume.text == "" ? vol = "" : vol = "/" + @@edit_volume.text
    page = "/manga/" + @@edit_name.text + vol + "/#{@@edit_chapter.text}/"
    MDownloader::Mangafox::download_chapter(page)
    @@edit_volume.text = @@edit_chapter.text = ""
    interface_status(nil)
    #alert("Done.")
  end
end