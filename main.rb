#By Hermes Passer in 11/06/2017
require 'thread'
require 'fileutils'
load 'external/updatewp.rb'
require_relative 'mdownloader/mfdownloader.rb'

include MDownloader
include Hermes::Update

# --------------------------------------------------- #
# If MangaFox change it domain url then update this.
# --------------------------------------------------- #
$SITE_URL = 'fanfox.net'
# --------------------------------------------------- #

#aparentemente as msgs não aparecem no log da gui

#debugar e ver por que o mesmo metodo esta sendo chamada varias vezes para o mesmo 
#link, mesmo que não tenham links repetidos e ele execute em um for sem change para repetir
$VERSION = '0.6'; $LOG = '';
manga = vol = chap = path = ''
dont_execute = false

def create_manga_folder(dirname)
	unless File.exist?("#{Dir.pwd}/#{dirname}")
		FileUtils.mkdir_p("#{Dir.pwd}/#{dirname}")
	end
	return "#{Dir.pwd}/#{dirname}"
end

def update
	up = Hermes::Update::UpdateByWebPage.new("mfdownloader", $VERSION, "gladiocitrico.blogspot.com.br/p/update.html")
	if up.update_is_avaliable	
		if up.update then puts($LOG = "Update successfully downloaded!")
		else puts($LOG = "Could not download the update, check your connection with the internet and try again or direct download from the site.")
		end
	else puts($LOG = "This program is updated.")
	end
end

def printlogo
	puts "\t    MangaFox Downloader #{$VERSION} Command Line"
	puts "\tby Hermes Passer (hermespasser.github.io)"
end

def printhelp
	puts "Wrong number of parameters."
	puts "\nParameters: "
	puts "\tFor download: m:[manga_name], v:[vol_name] (optional), c:[chapter_name], p:[destination_path]."
	puts "\tHelp: h:"
	puts "\tUpdate: u:"
	puts "No parameters to open gui of program."
end

printlogo
ARGV.each do |arg|
	arg_cmd = arg[0..1]
	case arg_cmd
	when "h:" 
		printhelp
		dont_execute = true
	when "u:"
		update
		dont_execute = true
	when "m:" then manga = arg[2, arg.length]
	when "v:" then vol 	 = arg[2, arg.length] 
	when "c:" then chap  = arg[2, arg.length]
	when "p:" then path  = arg[2, arg.length]
	end
end

if manga == "" && chap == "" && path == "" 
	if !dont_execute  
		if defined?(Shoes) then load "gui.rb"
		else puts "To use the gui, run with Shoes"
		end
	end
else
	if MDownloader::Mangafox.url_page_exits?($SITE_URL, "/manga/#{manga}/")
		if path == '' # If none path is set then create one in current program folder
			path = create_manga_folder("manga/#{manga}/#{vol}/#{chap}")
		end

		mfd = Mangafox.new(path, manga, vol, chap)
		mfd.download_chapter
	else puts "\"#{$SITE_URL}/manga/#{manga}/\" cannot be found"
	end
end