# encoding: utf-8

require 'diggit/developers_activity/activity_extractor/modules'
require 'diggit/developers_activity'

# The set of functions extracting modules metrics, ie, LoC and the number of bugfixes
#
#
module Diggit
	module DevelopersActivity
		module ModuleMetricsExtractor
			extend self

			def extract_module_metrics(source, source_options, db, repo)
				modules_bugfixes = extract_bugfixes(source_options['bug-fix-commits'], repo)
				modules_loc = extract_loc(source, db)

				modules_metrics = []
				modules_loc.each do |maudule, loc|
					modules_metrics << { project: source, 'module' => maudule, 'LoC' => loc,
														   'BugFixes' => modules_bugfixes[maudule].size }
				end
				modules_metrics
			end

			def extract_bugfixes(bug_fix_commits, repo)
				modules_bugfixes = Hash.new { |hash, key| hash[key] = Set.new }
				bug_fix_commits.each do |commit_oid|
					commit = repo.lookup(commit_oid)
					next if commit.parents.size != 1 # ignore merges
					diff = commit.parents[0].diff(commit, DIFF_OPTIONS)
					diff.find_similar!(DIFF_RENAME_OPTIONS)
					diff.each do |patch|
						maudule = ActivityExtractor::Modules.get_patch_module(patch)
						modules_bugfixes[maudule] = (modules_bugfixes[maudule] << commit_oid) unless maudule.nil?
					end
				end
				modules_bugfixes
			end

			def extract_loc(source, db)
				modules_loc = Hash.new(0)
				cloc_source = db.db['cloc-file'].find_one({ source: source })
				cloc_source['cloc'].each do |cloc_file|
					maudule = ActivityExtractor::Modules.get_module(cloc_file['path'])
					modules_loc[maudule] = modules_loc[maudule] + cloc_file['code'] unless maudule.nil?
				end
				modules_loc
			end
		end
	end
end
