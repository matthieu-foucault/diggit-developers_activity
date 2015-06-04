require "diggit/developers_activity/version"
require "diggit/developers_activity/activity_extractor"
require "diggit/developers_activity/module_metrics_extractor"
require "diggit/developers_activity/analyses"
require "diggit/developers_activity/workspace_init"

module Diggit
	module DevelopersActivity
		DIFF_OPTIONS = { ignore_whitespace: true, ignore_filemode: true }
		DIFF_RENAME_OPTIONS = { renames: true, ignore_whitespace: true }
	end
end
