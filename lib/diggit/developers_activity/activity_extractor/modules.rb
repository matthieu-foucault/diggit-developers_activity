# encoding: utf-8

require 'diggit/developers_activity/activity_extractor/renames'

module Diggit
	module DevelopersActivity
		module ActivityExtractor
			# Methods retrieving the module associated to a file.
			module Modules
				extend self

				MODULES_REGEXP = "modules"
				FILE_FILTER = "file-filter"

				def read_options(source, source_options, db)
					@source = source
					@db = db
					@release_files = files_from_cloc_analysis
					@modules_regexp = source_options.key?(MODULES_REGEXP) ? source_options[MODULES_REGEXP].map { |m| Regexp.new m } : []
					@file_filter = Regexp.new source_options[FILE_FILTER]
					@file_filter ||= //
				end

				def ignore_file?(path)
					!@release_files.include?(path) || (@file_filter =~ path).nil?
				end

				def get_module(path)
					path = Renames.apply(path)

					return nil if ignore_file?(path)
					@modules_regexp.each do |module_regexp|
						return module_regexp.to_s if module_regexp =~ path
					end

					path
				end

				def get_patch_module(patch)
					file = patch.delta.old_file[:path]
					get_module(file)
				end

				def files_from_cloc_analysis
					release_files = Set.new
					cloc_source = @db.db['cloc-file'].find_one({ source: @source })
					cloc_source["cloc"].each do |cloc_file|
						release_files << cloc_file["path"]
					end
					release_files
				end
			end
		end
	end
end
