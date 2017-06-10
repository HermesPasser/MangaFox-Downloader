Shoes.app(:title => "mfd about", width: 275, height: 220, resizable: false) do
	background white
	stack do
		caption("Mangafox Downloader #{$VERSION}")
		inscription("by Hermes Passer (gladiocitrico.blogspot.com)", :stroke => blue)
		inscription("Github: HermesPasser/mangafox-downloader")
		inscription "\t\t\tHow to download:"
		image("about.png")
	end
end