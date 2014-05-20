# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

# Patches
require 'patches/issue_patch'
require 'patches/project_patch'
require 'patches/version_patch'
require 'patches/projects_helper_patch'
require 'patches/query_patch'
require 'patches/time_entry_patch'
require 'patches/journal_patch'
require 'patches/journal_detail_patch'
require 'patches/queries_helper_patch'
require 'patches/versions_controller_patch'

# Hooks
require 'hooks/view_layouts_base_html_head_hook'
require 'hooks/view_issues_show_details_bottom_hook'
