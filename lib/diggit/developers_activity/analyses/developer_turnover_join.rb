# encoding: utf-8

require 'fileutils'

module Diggit
	module DevelopersActivity
		module Analyses
			class DeveloperTurnoverJoin < Join
				WORKING_DIR = './turnover/working_dir'
				WEB_WORKING_DIR = './turnover/web_working_dir'
				def run
					@addons[:R].database_host = '127.0.0.1'
					@addons[:R].working_dir = WORKING_DIR
					FileUtils.mkdir_p(WORKING_DIR)
					@addons[:R].web_working_dir = WEB_WORKING_DIR
					FileUtils.mkdir_p(WEB_WORKING_DIR)
					puts('Running R sript...')

					@addons[:R].eval <<-EOS
						if (require(developerTurnover) == FALSE) {
							if (require(devtools) == FALSE) {
								install.packages("devtools")
								library(devtools)
							}
							install_github("matthieu-foucault/RdeveloperTurnover")
							library(devtools)
						}

						developer_turnover(database_host, working_dir, web_working_dir)
						print("R script finished")
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
