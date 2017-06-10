require 'shoes'
require 'thread'
require './mdownloader/mfdownloader'
include MDownloader

$VERSION = "0.4"; $LOG = ""

def printlogo
	puts "\t    MangaFox Downloader #{$VERSION} Command Line"
	puts "\tby Hermes Passer (gladiocitrico.blogspot.com)"
end

@@mfd = Mangafox.new("", "", "", "")

case ARGV.length
when 1 then load "gui.rb"
when 4
	printlogo
	if MDownloader::Mangafox.url_page_exits?("mangafox.me", "/manga/#{ARGV[1]}/")
		@@mfd = Mangafox.new(ARGV[3], ARGV[1], "", ARGV[2])
		@@mfd.download_chapter
	else puts "\"mangafox.me/manga/#{ARGV[1]}/\" cannot be found"
	end
when 5
	printlogo
	if MDownloader::Mangafox.url_page_exits?("mangafox.me", "/manga/#{ARGV[1]}/")
		@@mfd = Mangafox.new(ARGV[4], ARGV[1], ARGV[2], ARGV[3])
		@@mfd.download_chapter
	else puts "\"mangafox.me/manga/#{ARGV[1]}/\" cannot be found"
	end
else
	puts "MangaFox Downloader #{$VERSION} Command Line Help"
	puts "Wrong number of parameters;"
	puts "\nParameters (in that order): manga, volume (optional), chapter, destination path."
	puts "No parameters open de gui of program."
end