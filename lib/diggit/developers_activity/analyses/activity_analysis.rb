# encoding: utf-8

require 'diggit/developers_activity/activity_extractor'

module Diggit
	module DevelopersActivity
		module Analyses
			# Abstract class for analyses using the dataset
			#
			# @abstract
			# @since 0.0.1
			class ActivityAnalysis < Analysis
				include ActivityExtractor

				def initialize(*args)
					super(*args)
					load_options
				end

				def source_options
					@addons[:sources_options][@source]
				end

				def load_options
					@releases = source_options["releases"]
					@all_releases = false
					@all_releases = @options["all_releases"] if @options.key? "all_releases"

					Authors.read_options(source_options)
					Modules.read_options(@source, source_options, @addons[:db])

					@modules_metrics = @options.key?("modules_metrics") ? @options["modules_metrics"] : true
				end
			end
		end
	end
end
