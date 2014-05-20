module RedmineProjectWorkflowExtension
  module Hooks
    class ViewLayoutsBaseHtmlHeadHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        # Head content
        head_content = ''

        # Include highcharts for graph controller
        if context[:controller] && context[:controller].is_a?(GraphController)
          head_content << javascript_include_tag('highcharts', :plugin => 'redmine_project_workflow_extension')
        end

        if context[:controller] && (  context[:controller].is_a?(ProjectsController) )
          head_content << stylesheet_link_tag('overview.css', :plugin => 'redmine_project_workflow_extension', :media => 'screen')
        end

        # Include javascript
        head_content
      end
    end
  end
end
