# encoding: utf-8

require 'diggit/developers_activity/module_metrics_extractor'
require 'diggit/developers_activity/analyses/activity_analysis'

module Diggit
	module DevelopersActivity
		module Analyses
			# Records module metrics (LoC and BugFixes)
			#
			#
			class ModuleMetricsAnalysis < ActivityAnalysis
				MODULES_METRICS_COL ||= "modules_metrics"

				def run
					super
					puts('Extracting LoC and #BugFixes')
					metrics = ModuleMetricsExtractor.extract_module_metrics(@source, src_opt[@source], db, repo)
					db.insert(MODULES_METRICS_COL, metrics)
				end

				def clean
					db.client[MODULES_METRICS_COL].find({ project: @source.url }).delete_many
				end
			end
		end
	end
end
