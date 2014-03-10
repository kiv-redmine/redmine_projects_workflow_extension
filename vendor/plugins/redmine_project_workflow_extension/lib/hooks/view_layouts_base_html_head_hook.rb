module RedmineProjectWorkflowExtension
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        if context[:controller] && (  context[:controller].is_a?(ProjectsController) )
          return stylesheet_link_tag('overview.css', :plugin => 'redmine_project_workflow_extension', :media => 'screen')
        else
          return ''
        end
      end
    end
  end
end
