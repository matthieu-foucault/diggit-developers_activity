# encoding: utf-8

module Diggit
	module DevelopersActivity
		module ActivityExtractor
			# Deals with authors identity merging
			module Authors
				extend self

				def read_options(source_options)
					@authors_merge = {}
					source_options['authors'].each_pair do |k, v|
						@authors_merge[k.downcase] = v.downcase
					end
				end

				def get_author(commit)
					author = commit.author[:name].downcase
					((defined? @authors_merge) && (@authors_merge.key? author)) ? @authors_merge[author] : author
				end
			end
		end
	end
end
