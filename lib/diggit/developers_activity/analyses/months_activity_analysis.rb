# encoding: utf-8

require 'diggit/developers_activity/analyses/activity_analysis'

module Diggit
	module DevelopersActivity
		module Analyses
			class MonthsActivityAnalysis < ActivityAnalysis
				MONTH_SECONDS ||= 3600 * 24 * 30

				OPT_MONTHS_TO_EXTRACT ||= 'months-to-extract'
				OPT_NUM_MONTHS_TO_EXTRACT ||= 'num-months-to-extract'

				MONTHS_AFTER_COL ||= "developer_activity_months_after"
				MONTHS_BEFORE_COL ||= "developer_activity_months_before"

				def initialize(*args)
					super(*args)
					# can be :before, :after, or :both
					@months_to_extract = @options.key?(OPT_MONTHS_TO_EXTRACT) ? @options[OPT_MONTHS_TO_EXTRACT].to_sym : :before
					@num_months_to_extract = @options.key?(OPT_NUM_MONTHS_TO_EXTRACT) ? @options[OPT_NUM_MONTHS_TO_EXTRACT].to_i : 12
				end

				def run
					extract_months_before unless @months_to_extract == :after
					extract_months_after unless @months_to_extract == :before
				end

				def clean
					@addons[:db].db[MONTHS_BEFORE_COL].remove({ project: @source }) unless @months_to_extract == :after
					@addons[:db].db[MONTHS_AFTER_COL].remove({ project: @source }) unless @months_to_extract == :before
				end

				def extract_months_before
					Renames.clear
					r_0 = @repo.lookup(source_options["cloc-commit-id"])
					t_first = @repo.lookup(source_options["R_first"]).author[:time]

					t_0 = r_0.author[:time]

					walker = Rugged::Walker.new(@repo)
					walker.sorting(Rugged::SORT_DATE)
					walker.push(r_0)

					t_previous_month = t_0 - MONTH_SECONDS
					month_num = 1
					commits = []
					walker.each do |commit|
						t = commit.author[:time]
						Renames.extract_commit_renames(commit, true)
						commits << commit if commit.parents.size == 1
						if t < t_previous_month || t < t_first
							puts "Month #{month_num}, #{commits.size} commits"
							m = extract_developers_activity(@source, commits, month_num)
							@addons[:db].db[MONTHS_BEFORE_COL].insert(m) unless m.empty?
							month_num += 1
							t_previous_month -= MONTH_SECONDS
							commits = []
						end
						break if t < t_first || month_num > @num_months_to_extract
					end
				end

				def extract_months_after
					Renames.clear
					r_0 = @repo.lookup(source_options["cloc-commit-id"])
					r_last = @repo.lookup(source_options["R_last"])
					t_0 = r_0.author[:time]

					walker = Rugged::Walker.new(@repo)
					walker.sorting(Rugged::SORT_DATE | Rugged::SORT_REVERSE)
					walker.push(r_last)
					t_next_month = t_0 + MONTH_SECONDS
					month_num = 1
					commits = []
					walker.each do |commit|
						t = commit.author[:time]
						next if t < t_0
						Renames.extract_commit_renames(commit, false)
						commits << commit if commit.parents.size == 1
						if t > t_next_month
							puts "Month #{month_num}, #{commits.size} commits"
							m = ActivityExtractor.extract_developers_activity(@source, commits, month_num)
							@addons[:db].db[MONTHS_AFTER_COL].insert(m) unless m.empty?
							month_num += 1
							t_next_month += MONTH_SECONDS
							commits = []
						end
						break if month_num > @num_months_to_extract
					end
				end
			end
		end
	end
end
