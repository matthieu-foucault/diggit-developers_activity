# encoding: utf-8

require 'diggit/developers_activity/analyses/activity_analysis'

module Diggit
	module DevelopersActivity
		module Analyses
			class CommitsFilesAnalysis < ActivityAnalysis
				COL ||= "commits-files"
				MONTH_SECONDS ||= 3600 * 24 * 30
				def run
					super
					r_0 = repo.lookup(src_opt[@source]["cloc-commit-id"])
					t_0 = r_0.author[:time]

					walker = Rugged::Walker.new(repo)
					walker.sorting(Rugged::SORT_DATE)
					walker.push(r_0)

					t_stop = t_0 - 12 * MONTH_SECONDS
					commits_files = []
					Modules.files_as_modules
					walker.each do |commit|
						next unless commit.parents.size == 1
						Renames.extract_commit_renames(commit, true)
						commit.parents.each do |parent|
							diff = parent.diff(commit, DIFF_OPTIONS)
							diff.find_similar!(DIFF_RENAME_OPTIONS)
							diff.each do |patch|
								maudule = Modules.get_patch_module(patch)
								next if maudule.nil?

								commits_files << { file: maudule, commit: commit.oid.to_s, project: @source.url }
							end
						end
						#break if commit.author[:time] < t_stop
					end
					db.insert(COL, commits_files)
				end

				def clean
					db.client[COL].find({ project: @source.url }).delete_many
				end
			end
		end
	end
end
