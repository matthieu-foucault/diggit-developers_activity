# encoding: utf-8

require 'diggit/developers_activity/activity_extractor'
require 'oj'

module Diggit
	module DevelopersActivity
		module Analyses
			# Abstract class for analyses using the dataset
			#
			# @abstract
			# @since 0.0.1
			class ActivityAnalysis < Diggit::Analysis
				include ActivityExtractor
				require_addons 'db', 'src_opt'

				def run
					load_options
				end

				def load_options
					@all_releases = false
					@all_releases = @options["all_releases"] if @options.key? "all_releases"
					if @options.key? 'alternative_modules'
						source_options['modules'] = Oj.load_file(@options['alternative_modules'])[@source.url]['modules']
					end
					@modules_metrics = @options.key?("modules_metrics") ? @options["modules_metrics"] : true

					return if src_opt[@source].nil?
					@releases = src_opt[@source]["releases"]
					Authors.read_options(src_opt[@source])
					source_options = src_opt[@source]
					Modules.read_options(@source, source_options, db.client)
				end
			end
		end
	end
end
