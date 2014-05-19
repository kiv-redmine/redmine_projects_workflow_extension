module RedmineProjectWorkflowExtension
  module Hooks
    class ViewIssuesShowDetailsBottomHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, :partial => 'issues/workflow_extension'
    end
  end
end
