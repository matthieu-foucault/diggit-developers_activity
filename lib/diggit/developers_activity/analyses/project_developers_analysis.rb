# encoding: utf-8

require 'diggit/developers_activity/analyses/activity_analysis'

module Diggit
	module DevelopersActivity
		module Analyses
			# Records the activity of developers at the project level, ie, the date at which developers commit
			#
			# @since 0.0.1
			class ProjectDevelopersAnalysis < ActivityAnalysis
				COL ||= "devs_commit_dates"
				def run
					super
					puts('Extracting project-level activity')
					r_last = repo.lookup(src_opt[@source]["R_last"])
					r_first_time = repo.lookup(src_opt[@source]["R_first"]).author[:time]

					walker = Rugged::Walker.new(repo)
					walker.sorting(Rugged::SORT_DATE)
					walker.push(r_last)

					devs = []
					walker.each do |commit|
						t = commit.author[:time]
						author = Authors.get_author(commit)
						devs << { project: @source.url, author: author, time: t }

						break if t < r_first_time
					end

					db.insert(COL, devs)
				end

				def clean
					db.client[COL].find({ project: @source.url }).delete_many
				end
			end
		end
	end
end
