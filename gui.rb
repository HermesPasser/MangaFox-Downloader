# require 'shoes'

@@mfd = Mangafox.new("", "", "", "")
Shoes.app(:title => "Mangafox Downloader #{$VERSION}", width: 570, height: 310, resizable: false) do

	flow do
		stack(:margin => 10, :width => 350) do  
			flow do 
				inscription(link("About").click {load "about.rb"})
				inscription("")
				inscription(link("Update").click {update})
				inscription("")
				@thumb_alt = inscription("No loaded manga")
			end
			
			flow do
				para("Path \t") 
				@edit_path = edit_line(state: "disabled", width: 120) {edit_Change}
				button("Change") {change_Click}
			end

			flow do
				para("Name \t") 
				@edit_name = edit_line(width: 200) {edit_Change}
			end

			flow do
				para "\t\t"
				@search_manga = button("Search manga", width: 200) {run_in_thread {search_manga_Click}}
			end

			flow do
				para("Vol \t\t")
				@edit_volume = edit_line(state: "disabled", width: 35) {edit_Change}
				para(" Chapter\t\t")
				@edit_chapter = edit_line(state: "disabled", width: 64) {edit_Change}
			end

			flow do
				para "\t\t"
				@download = button("Download", state: "disabled", width: 100) {run_in_thread {download_Click}}
				button("Cancel", width: 100) {cancel_Click and $LOG = "Aborted."}
			end
			
			flow(:width => 550, :height => 80, :scroll => true) do
				background white
				border black
				@log = inscription
			end
		end

		stack(:margin => 10, :width => -350) do
			@manga_thumb = image("cover.png", :width => 200, :height => 200)
		end
	end
	
	every 1 do
		@log.text = $LOG
		if @thread.instance_of?(Thread) && !@thread.alive?
			cancel_Click
			@thread = nil
		end
	end

	def run_in_thread
		@thread = Thread.new{yield}
	end

	def interface_status(state)
		@edit_name.state = @edit_volume.state = @edit_chapter.state = @search_manga.state = @download.state = state
	end

	def clear_search
		interface_status(false)
		@manga_thumb.path = "cover.png"
		@thumb_alt.text = "No loaded manga"
		@edit_name.state = @search_manga.state = nil
	end

	def edit_Change
		@edit_name.text = @edit_name.text.gsub(" ", "_").downcase
	end

	def change_Click
		@edit_path.text = ask_open_folder
		#save path here...
	end
	
	def search_manga_Click
		edit_Change
		if @edit_name.text == ""
			clear_search
			return
		end

		@thumb_alt.text = "Loading..."
		@edit_name.state = @search_manga.state = @edit_volume.state = @download.state = "disabled"

		exits = MDownloader::Mangafox.url_page_exits?("mangafox.me", "/manga/#{@edit_name.text}/")
		puts("\"mangafox.me/manga/#{@edit_name.text}/\" exits? #{exits}")
		
		if exits
			@@mfd.manga_name = @edit_name.text
			link = @@mfd.get_cover
			@manga_thumb.path = link
			@thumb_alt.text = @edit_name.text.gsub("_", " ")
			@edit_chapter.state = @search_manga.state = @edit_volume.state = @download.state = @edit_name.state = nil
		else 
			$LOG = "Cannot find the manga."
			clear_search
		end
	end

	def download_Click
		if @edit_path.text == "" or @edit_path.text  == nil
			$LOG = "Invalid path."
			return
		end
		interface_status("disabled")
		
		@@mfd.path_to_download = @edit_path.text
		@@mfd.manga_volume =  @edit_volume.text
		@@mfd.manga_chapter = @edit_chapter.text
		
		@@mfd.download_chapter
		$LOG = "Done."
		search_manga_Click
	end
	
	def cancel_Click
		@thread.kill
		interface_status(nil)		
	end
end