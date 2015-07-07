# encoding: utf-8

require 'fileutils'

module Diggit
	module DevelopersActivity
		module Analyses
			class DeveloperTurnoverJoin < Diggit::Join
				require_addons 'r'
				require_analyses('module_metrics_analysis', 'months_activity_analysis',
				                 'project_developers_analysis', 'releases_activity_analysis')
				WORKING_DIR = './turnover/results/'
				WEB_WORKING_DIR = './turnover/web_page_results/'
				def run
					db_match = @options[:mongo][:url].match(%r{^mongodb://(.+):27017/(.+)$})
					r.database_host = db_match[1]
					r.database_name = db_match[2]
					r.working_dir = WORKING_DIR
					FileUtils.mkdir_p(WORKING_DIR)
					r.web_working_dir = WEB_WORKING_DIR
					FileUtils.mkdir_p(WEB_WORKING_DIR)
					puts('Running R sript...')

					r.eval <<-EOS
						options(warn=-1)
						if (require(developerTurnover) == FALSE) {
							if (require(devtools) == FALSE) {
								install.packages("devtools", repos = "http://cran.rstudio.com")
								library(devtools)
							}
							install_github("matthieu-foucault/RdeveloperTurnover")
							library(devtools)
							library(developerTurnover)
						}

						developer_turnover(database_host, database_name, working_dir, web_working_dir)
						print("R script finished")
						options(warn=0)
					EOS
				end

				def clean
					FileUtils.rm_rf(WORKING_DIR)
					FileUtils.rm_rf(WEB_WORKING_DIR)
				end
			end
		end
	end
end
