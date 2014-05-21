# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>
require 'redmine'
require 'dispatcher'

ActionController::Dispatcher.to_prepare :redmine_project_workflow_extension do
  require_dependency 'version'
  require_dependency 'project'
  require_dependency 'projects_helper'
  require_dependency 'journal'
  require_dependency 'journal_detail'
  require_dependency 'issue'
  require_dependency 'query'
  require_dependency 'time_entry'
  require_dependency 'queries_helper'
  require_dependency 'versions_controller'

  unless VersionsController.included_modules.include?(RedmineProjectWorkflowExtension::Patches::VersionsControllerPatch)
    VersionsController.send(:include, RedmineProjectWorkflowExtension::Patches::VersionsControllerPatch)
  end

  unless Journal.included_modules.include?(RedmineProjectWorkflowExtension::Patches::JournalPatch)
    Journal.send(:include, RedmineProjectWorkflowExtension::Patches::JournalPatch)
  end

  unless JournalDetail.included_modules.include?(RedmineProjectWorkflowExtension::Patches::JournalDetailPatch)
    JournalDetail.send(:include, RedmineProjectWorkflowExtension::Patches::JournalDetailPatch)
  end

  unless TimeEntry.included_modules.include?(RedmineProjectWorkflowExtension::Patches::TimeEntryPatch)
    TimeEntry.send(:include, RedmineProjectWorkflowExtension::Patches::TimeEntryPatch)
  end

  unless QueriesHelper.included_modules.include?(RedmineProjectWorkflowExtension::Patches::QueriesHelperPatch)
    QueriesHelper.send(:include, RedmineProjectWorkflowExtension::Patches::QueriesHelperPatch)
  end

  unless Query.included_modules.include?(RedmineProjectWorkflowExtension::Patches::QueryPatch)
    Query.send(:include, RedmineProjectWorkflowExtension::Patches::QueryPatch)
  end

  unless Issue.included_modules.include?(RedmineProjectWorkflowExtension::Patches::IssuePatch)
    Issue.send(:include, RedmineProjectWorkflowExtension::Patches::IssuePatch)
  end

  unless Project.included_modules.include? RedmineProjectWorkflowExtension::Patches::ProjectPatch
    Project.send(:include, RedmineProjectWorkflowExtension::Patches::ProjectPatch)
  end

  unless Version.included_modules.include? RedmineProjectWorkflowExtension::Patches::VersionPatch
    Version.send(:include, RedmineProjectWorkflowExtension::Patches::VersionPatch)
  end

  unless ProjectsHelper.included_modules.include? RedmineProjectWorkflowExtension::Patches::ProjectsHelperPatch
    ProjectsHelper.send(:include, RedmineProjectWorkflowExtension::Patches::ProjectsHelperPatch)
  end
end


Redmine::Plugin.register :redmine_project_workflow_extension do
  name 'Redmine Project Workflow Extension plugin'
  author 'Jan Strnadek <jan.strnadek@gmail.com>'
  description 'Extension for redmine project workflow'
  version '0.0.1'
  url 'https://github.com/Strnadj/redmine13_project_workflow_extension'
  author_url 'mailto:jan.strnadek@gmail.com'
  requires_redmine :version_or_higher => '1.3'

  # Menu view Graphs in project menu
  menu :project_menu, :charts, { :controller => :graph, :action => :burndown }, :caption => :label_charts_menu, :after => :new_issue, :param => :project_id

  # Permissions
  project_module :workflow_module do
    # Permission for view graphs
    permission :view_graphs, {
      :graph => [:burndown, :issue_status, :show_plot_band, :burnup]
    }, :require => :loggedin

    # Manage milestones permission
    permission :manage_milestones, {
      :milestones => [ :new, :create, :edit, :update, :destroy, :show ]
    }

    # Manage iterations
    permission :manage_iterations, {
      :iterations => [ :new, :create, :edit, :update, :destroy, :show ]
    }
  end
end
