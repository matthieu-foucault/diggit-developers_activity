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
					puts('Extracting LoC and #BugFixes')
					metrics = ModuleMetricsExtractor.extract_module_metrics(@source, source_options, @addons[:db], @repo)
					@addons[:db].db[MODULES_METRICS_COL].insert(metrics)
				end

				def clean
					@addons[:db].db[MODULES_METRICS_COL].remove({ project: @source })
				end
			end
		end
	end
end
