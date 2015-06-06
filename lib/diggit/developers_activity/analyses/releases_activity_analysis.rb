# encoding: utf-8

require 'diggit/developers_activity/analyses/activity_analysis'

module Diggit
	module DevelopersActivity
		module Analyses
			#
			# @since 0.0.1
			class ReleasesActivityAnalysis < ActivityAnalysis
				COL_DEVELOPERS_RELEASE_ACTIVITY ||= "developer_activity_release"

				def commits_between(new_commit, old_commit)
					walker = Rugged::Walker.new(@repo)
					walker.sorting(Rugged::SORT_DATE)
					walker.push(@repo.lookup(new_commit))

					t_old = @repo.lookup(old_commit).author[:time]
					commits = []

					walker.each do |commit|
						t_commit = commit.author[:time]
						break if t_commit < t_old
						commits << commit
					end
					commits
				end

				def run
					releases = source_options["releases"]
					(0..(releases.length - 2)).each do |i|
						release_commits = commits_between(releases[i], releases[i + 1])
						release_commits.each { |commit| Renames.extract_commit_renames(commit) }
						m = extract_developers_activity(@source, release_commits, i)
						@addons[:db].db[COL_DEVELOPERS_RELEASE_ACTIVITY].insert(m) unless m.empty?
					end
				end

				def clean
					@addons[:db].db[COL_DEVELOPERS_RELEASE_ACTIVITY].remove({ project: @source })
				end
			end
		end
	end
end
