require 'redmine'
require 'dispatcher'

ActionController::Dispatcher.to_prepare :redmine_project_workflow_extension do
  require_dependency 'version'
  require_dependency 'project'
  require_dependency 'projects_helper'
  require_dependency 'issue'
  require_dependency 'query'
  require_dependency 'queries_helper'

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

  # Permissions
  project_module :workflow_module do
    permission :manage_milestones, {
      :milestones => [ :new, :create, :update, :destroy, :show ]
    }
    permission :manage_iterations, {
      :iterations => [ :create, :update, :destroy, :show ]
    }
  end
end
