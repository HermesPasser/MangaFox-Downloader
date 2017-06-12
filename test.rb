# C:\tmp\shoes4\bin\shoes
# tamen_de_gushi



# cshoes main.rb naruto v70 c669 C:\Users\Diogo\Dropbox\zProjects\Dev\Public\
require 'thread'

=begin
	ruby "C:\Users\Diogo\Dropbox\zProjects\Dev\Public\mangafox downloader\test.rb"
	dado um numero x de threads
	y threads sejam executadas em paralelo
	e quando uma morra, outra seja ativada até que não restem mais
	
	considerando que:
	x = 20
	y = 10
=end

ary = []


MAX_THREAD = 10
current_threads = 0
length = 20

while current_threads < length
	
	# if current_threads > MAX_THREAD
		# ary.each(&:join)
		# p "===================================================================="
		# break
	# end
	
	if current_threads == MAX_THREAD || current_threads == (length -1)
		ary.each(&:join)
		p "===================================================================="
	end
	p "#{Thread.list.length} ------------"
	ary << Thread.new{
		50.times do |a|
			p a
		end
		# current_threads -= 1
	}
	current_threads += 1
end

p "#{Thread.list.length} ------------"
 p '---'
p current_threads 
