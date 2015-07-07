# encoding: utf-8

require 'fileutils'
require 'dgit'

module Diggit
	module DevelopersActivity
		# Initializes a workspace with the developers activity dataset
		#
		#
		module WorkspaceInit
			extend self

			SOURCES_LIST = 'sources.list'
			SOURCES_OPTIONS_FILE = 'sources_options'
			OPTIONS_FILE = 'options'
			DGIT_FOLDER = '.dgit'

			def init
				link_analyses_folder
				link_joins_folder
				Dig.init_dir('.')
				Dig.init('.')
				Dig.it.config.add_analysis('cloc_per_file')
				Dig.it.config.add_analysis('module_metrics_analysis')
				Dig.it.config.add_analysis('months_activity_analysis')
				Dig.it.config.add_analysis('project_developers_analysis')
				Dig.it.config.add_analysis('releases_activity_analysis')

				Dig.it.config.add_join('developer_turnover_join')

				dataset_dir = File.expand_path('dataset', File.dirname(__FILE__))

				IO.readlines(File.join(dataset_dir, SOURCES_LIST)).select { |l| !l.strip.empty? && !l.start_with?('#') }
				  .each { |url| Dig.it.journal.add_source(url.strip) }

				FileUtils.cp(File.join(dataset_dir, OPTIONS_FILE), DGIT_FOLDER)
				FileUtils.cp(File.join(dataset_dir, SOURCES_OPTIONS_FILE), DGIT_FOLDER)
			end

			def link_analyses_folder
				analyses_dir = File.expand_path('analyses', File.dirname(__FILE__))
				home = File.join(Dir.home, DGIT_FOLDER, 'plugins', 'analysis')
				FileUtils.mkdir_p(home)
				FileUtils.ln_sf(analyses_dir, File.join(home, 'developers_activity'))
			end

			def link_joins_folder
				analyses_dir = File.expand_path('joins', File.dirname(__FILE__))
				home = File.join(Dir.home, DGIT_FOLDER, 'plugins', 'join')
				FileUtils.mkdir_p(home)
				FileUtils.ln_sf(analyses_dir, File.join(home, 'developers_activity'))
			end
		end
	end
end
