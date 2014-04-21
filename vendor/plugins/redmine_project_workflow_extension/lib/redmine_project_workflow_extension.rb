# Redmine initalize file
require 'dispatcher'

# Patches
require 'patches/issue_patch'
require 'patches/project_patch'
require 'patches/version_patch'
require 'patches/projects_helper_patch'
require 'patches/query_patch'
require 'patches/time_entry_patch'
require 'patches/journal_detail_patch'
require 'patches/queries_helper_patch'
require 'hooks/view_layouts_base_html_head_hook'
require 'hooks/view_issues_show_details_bottom_hook'
