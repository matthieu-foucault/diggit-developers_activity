# encoding: utf-8

require 'diggit/developers_activity/activity_extractor/renames'
require 'diggit/developers_activity/activity_extractor/modules'
require 'diggit/developers_activity/activity_extractor/authors'
require 'diggit/developers_activity'

module Diggit
	module DevelopersActivity
		# Set of functions extracting developers activity for a given set of commits
		module ActivityExtractor
			extend self

			def extract_developers_activity(source, commits, commits_group_id = nil)
				return [] if commits.empty?
				contributions = Hash.new { |hash, key| hash[key] = { touches: 0, churn: 0 } }
				num_commits = 0

				commits.each do |commit|
					num_commits += 1

					author = Authors.get_author(commit)

					commit.parents.each do |parent|
						diff = parent.diff(commit, DIFF_OPTIONS)
						diff.find_similar!(DIFF_RENAME_OPTIONS)
						diff.each do |patch|
							maudule = Modules.get_patch_module(patch)
							next if maudule.nil?

							key = { author: author, 'module' => maudule }
							contributions[key] = { touches: contributions[key][:touches] + 1,
																		churn: contributions[key][:churn] + patch.stat[0] + patch.stat[1] }
						end
					end
				end

				fist_commit_date = commits[0].author[:time]

				# compute metrics and write to result
				developer_metrics = []
				contributions.each do |key, value|
					developer_metrics << { project: source, developer: key[:author], 'module' => key['module'],
						touches: value[:touches], churn: value[:churn], releaseDate: fist_commit_date,
						commits_group_id: commits_group_id }
				end
				developer_metrics
			end
		end
	end
end
