# encoding: utf-8

require 'fileutils'

module Diggit
	module DevelopersActivity
		# Initializes a workspace with the developers activity dataset
		#
		#
		module WorkspaceInit
			extend self

			DIGGIT_RC = '.dgitrc'
			DIGGIT_SOURCES_OPTIONS = '.dgitsources-options'
			SOURCES_LIST = 'sources.list'

			INCLUDES_FOLDER = 'includes'
			DIGGIT_FOLDER = ".diggit"

			def init
				`dgit init`
				dataset_dir = File.expand_path('dataset', File.dirname(__FILE__))

				FileUtils.cp(File.expand_path(DIGGIT_RC, dataset_dir), '.')
				FileUtils.cp(File.expand_path(DIGGIT_SOURCES_OPTIONS, dataset_dir), '.')
				FileUtils.cp(File.expand_path(SOURCES_LIST, dataset_dir), '.')

				analyses_dir = File.expand_path('analyses', File.dirname(__FILE__))
				home = File.expand_path(INCLUDES_FOLDER, File.expand_path(DIGGIT_FOLDER, Dir.home))
				FileUtils.ln_s(analyses_dir, File.expand_path('developers_activity', home))
			end
		end
	end
end
