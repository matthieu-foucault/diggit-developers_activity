# encoding: utf-8

require 'diggit/developers_activity'

module Diggit
	module DevelopersActivity
		module ActivityExtractor
			# Stores file renaming operations.
			# Allows to retrieve the initial path of a file after having performed a diff on the renaming commits.
			#
			# @since 0.0.1
			module Renames
				extend self

				def hash
					@renames_hash ||= {}
				end

				def clear
					@renames_hash = {}
				end

				# Adds a rename operation to the list, if the rename does not create a cycle
				#
				# @return true if the rename was added, false otherwise
				def add(src_path, dest_path)
					# check for cycle, ie, if there is a rename path from dest to src
					path = dest_path
					while hash.key? path
						path = hash[path]
						return false if path == src_path
					end

					hash[src_path] = dest_path
					true
				end

				# Apply all renaming operations found on the given path
				#
				# @return the path of the file at the S0 snapshot
				def apply(path)
					path = hash[path] while hash.key? path
					path
				end

				def extract_commit_renames(commit, walk_backwards = true)
					commit.parents.each do |parent|
						diff = parent.diff(commit, DIFF_OPTIONS)
						diff.find_similar!(DIFF_RENAME_OPTIONS)
						diff.each do |patch|
							next unless patch.delta.renamed?
							if walk_backwards
								new_path = patch.delta.new_file[:path]
								renamed_path = patch.delta.old_file[:path]
							else
								renamed_path = patch.delta.new_file[:path]
								new_path = patch.delta.old_file[:path]
							end
							add(renamed_path, new_path)
						end
					end
				end

				def extract_renames(walker, walk_backwards = true)
					walker.each { |commit| extract_commit_renames(commit, walk_backwards) }
				end
			end
		end
	end
end
