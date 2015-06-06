# encoding: utf-8

require 'fileutils'

module Diggit
	module DevelopersActivity
		module Analyses
			class DeveloperTurnoverJoin < Diggit::Join
				def run
					@addons[:R].database_host = '127.0.0.1'
					@addons[:R].working_dir = './turnover/working_dir'
					FileUtils.mkdir_p(@addons[:R].working_dir)
					@addons[:R].web_working_dir = './turnover/web_working_dir'
					FileUtils.mkdir_p(@addons[:R].web_working_dir)
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
			end
		end
	end
end
