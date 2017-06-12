#By Hermes Passer in 11/06/2017
require 'thread'
load 'external/updatewp.rb'
require_relative 'mdownloader/mfdownloader.rb'

include MDownloader
include Hermes::Update
#aparentemente as msgs não aparecem no log da gui

#debugar e ver por que o mesmo metodo esta sendo chamada varias vezes para o mesmo 
#link, mesmo que não tenham links repetidos e ele execute em um for sem change para repetir
$VERSION = "0.5"; $LOG = ""
manga = vol = chap = path = ""
dont_execute = false

def printlogo
	puts "\t    MangaFox Downloader #{$VERSION} Command Line"
	puts "\tby Hermes Passer (gladiocitrico.blogspot.com)"
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
		up = Hermes::Update::UpdateByWebPage.new("mfdownloader", $VERSION, "gladiocitrico.blogspot.com.br/p/update.html")
		if up.update_is_avaliable	
			if up.update
				puts("Update successfully downloaded!")
			else
				puts("Could not download the update, check your connection with the internet and try again or direct download from the site.")
			end
		else
			puts("This program is updated.")
		end
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
	if MDownloader::Mangafox.url_page_exits?("mangafox.me", "/manga/#{manga}/")
		mfd = Mangafox.new(path, manga, vol, chap)
		mfd.download_chapter
	else puts "\"mangafox.me/manga/#{manga}/\" cannot be found"
	end
end