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
		end
	end
end
