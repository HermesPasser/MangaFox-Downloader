# require 'shoes'

# Remove cache folder created in previous run
remove_folder(create_local_folder('.cache'))

$mfd = Mangafox.new("", "", "", "")
Shoes.app(:title => "Mangafox Downloader #{$VERSION}", width: 570, height: 310, resizable: false) do
	flow do
		stack(:margin => 10, :width => 350) do  
			flow do 
				inscription( link("About").click {load "about.rb"} )
				inscription("")
				inscription(link("Update").click { update })
				inscription("")
				@thumb_alt = inscription("No loaded manga")
			end
			
			flow do
				para("Path \t") 
				@edit_path = edit_line(state: "disabled", width: 120) { edit_Change }
				button("Change") { change_Click }
			end

			flow do
				para("Name \t") 
				@edit_name = edit_line(width: 200) { edit_Change }
			end

			flow do
				para "\t\t"
				@btn_search = button("Search manga", width: 200) { run_in_thread { search_manga_Click } }
			end

			flow do
				para("Vol \t\t")
				@edit_volume = edit_line(state: "disabled", width: 35) {edit_Change}
				para(" Chapter\t\t")
				@edit_chapter = edit_line(state: "disabled", width: 64) {edit_Change}
			end

			flow do
				para "\t\t"
				@btn_download = button("Download", state: "disabled", width: 100) {run_in_thread { download_Click }}
				button("Cancel", width: 100) {cancel_Click and $LOG = "Aborted."}
			end
			
			flow(:width => 550, :height => 80, :scroll => true) do
				background white
				border black
				@log = inscription
			end
		end

		stack(:margin => 10, :width => -350) do
			@img_thumb = image("cover.png", :width => 200, :height => 200)
		end
	end
	
	every 1 do
		@log.text = $LOG
		if @thread.instance_of?(Thread) && !@thread.alive?
			cancel_Click
			@thread = nil
		end
	end

	# downlaod the cover because set 'path' as a url link is not working anymore
	def set_cover(url)
		tempdir = create_local_folder('.cache')
		$mfd.path_to_download = tempdir
		$mfd.download_image(url, 'temp')
		@img_thumb.path = File.join(tempdir, 'temp.jpg')
	end
	
	def run_in_thread
		@thread = Thread.new{ yield }
	end

	def clear_search
		enable_interface('disabled')
		@img_thumb.path = "cover.png"
		@thumb_alt.text = "No loaded manga"
		@edit_name.state = @btn_search.state = nil
	end

	def edit_Change
		@edit_name.text = @edit_name.text.gsub(" ", "_").downcase
	end

	def change_Click
		@edit_path.text = ask_open_folder
	end
	
	def search_manga_Click
		edit_Change
		if @edit_name.text == ""
			clear_search
			return
		end
		
		$LOG = ''
		@thumb_alt.text = "Loading..."
		@edit_name.state = @btn_search.state = @edit_volume.state = @btn_download.state = "disabled"
		exits = MDownloader::Mangafox.url_page_exits?($SITE_URL, "/manga/#{@edit_name.text}/")

		if exits
			$mfd.manga_name = @edit_name.text
			set_cover($mfd.get_cover)
			
			@thumb_alt.text = @edit_name.text.gsub("_", " ")
			
			# bacause cannot call the methods in another thread?
			@edit_chapter.state = @btn_search.state = @edit_volume.state = @btn_download.state = @edit_name.state = nil
		else 			
			$LOG = "Cannot find the manga."
			clear_search
		end
	end

	def download_Click
		if @edit_path.text == '' or @edit_path.text == nil
			$LOG = "Invalid path."
			return
		end
		enable_interface('disabled')
		
		$mfd.path_to_download = @edit_path.text
		$mfd.manga_volume =  @edit_volume.text
		$mfd.manga_chapter = @edit_chapter.text
		
		$mfd.download_chapter
		$LOG = "Done."
		search_manga_Click
	end
	
	def enable_interface(state)
		@edit_name.state = @btn_search.state = state # btn path not included
	end
	
	# Not used
	# def enable_download_interface(state)
		# @edit_volume.state = @edit_chapter.state = @btn_download.state = state
	# end
	
	def cancel_Click
		if @thread.instance_of?(Thread)
			@thread.kill
		end
		enable_interface(nil)		
	end
end