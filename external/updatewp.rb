#---------------------------- UpdateByWebPage ------------------------------#
# by Hermes Passer				                                            #
# in 19-04-2017					                                            #
# GitHub HermesPasser/UpdateByWebPage                                       #
#---------------------------------------------------------------------------#
# Update system for ruby programs that checks on a page specifies whether   #
#updates are available.                                                     #
#---------------------------------------------------------------------------#
	
#require_relative 'unpackwin'
require 'fileutils'
require 'net/http'
require 'open-uri'
require 'openssl'

module Hermes
	module Update
		class UpdateByWebPage
			attr_accessor :project_id,  :current_version
			attr_reader   :update_link_domain, :update_link_page
			
			def initialize id, version, link
				@project_id = id
				@current_version = version
				set_update_link link
			end
			
			def set_update_link link
				link = link.gsub("https://", "").gsub("http://", "")
				if link.to_s.include? "/"
					@update_link_domain = link[0, link.index("/")]
					@update_link_page = link[link.index("/"), link.length]
				else
					@update_link_domain = link
					@update_link_page = "/"
				end
			end
			
			def get_update_link
				@update_link_domain + update_link_page
			end
			
			def update directory = ""
				if !update_is_avaliable then return false end
				
				#Url
				link_all = get_download_link.gsub("http://", "https://")
				link_all = !link_all.include?("https://") ? "https://" + link_all : link_all
		
				#File name and destination
				file_name = link_all[link_all.rindex("/") + 1, link_all.length]
				if directory == "" or directory == nil
					directory = Dir.pwd
				else
					if directory[directory.length - 1] == "/"
						directory = directory[0, directory.length - 1]
					end
				end

				file_name = "#{directory}/#{file_name}"
				
				#Download
				begin
				  open(file_name, 'wb') do |file|
						file << open(link_all, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
					end
				rescue Exception => e
					puts e
					return false
				end
				return true
			end
			
			def update_is_avaliable
				unless get_download_link == nil
					return current_version.to_f <= get_version.to_f
				end
				return false
			end
			
			def get_download_link
				i = get_update_info
				return i[2].strip
			end
			
			private def get_version
				i = get_update_info
				i[1].strip
			end			
			
			private def get_update_info
				html = get_html.split(/\n/)
				line = ""
				
				html.each do |i|
					if i.include? "updater[" and i.include? "]"
						i = i[i.index("[") + 1, i.length]
						i = i[0, i.index("]")]
						line = i.split(/,/)
						
						if line[0] == project_id then return line end
					end
				end
				return [nil, nil, nil]
			end
			
			public def get_html
				begin
					retries ||= 0
					Net::HTTP.get(@update_link_domain, @update_link_page)
				rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
					if (retries += 1) < 3 then retry
					else return false
					end
				end
			end
		end
	end
end