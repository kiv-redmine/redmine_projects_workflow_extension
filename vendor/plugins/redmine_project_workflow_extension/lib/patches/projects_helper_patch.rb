module RedmineProjectWorkflowExtension
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.class_eval do
          def project_settings_tabs_with_more_tabs
            tabs = project_settings_tabs_without_more_tabs
            index = tabs.index({:name => 'versions', :action => :manage_versions, :partial => 'projects/settings/versions', :label => :label_version_plural})

            # Insert after version!
            if index
              tabs.insert(index, {:name => "iterations", :action => :manage_iterations, :partial => "projects/settings/iterations", :label => :label_iteration_plural})
              tabs.insert(index, {:name => "milestones", :action => :manage_milestones, :partial => "projects/settings/milestones", :label => :label_milestone_plural})
            end
            tabs
          end
          alias_method_chain :project_settings_tabs, :more_tabs

          # Link to milestone
          def link_to_milestone(milestone, options = {})
            return '' unless milestone && milestone.is_a?(Milestone)
            link_to milestone.name, { :controller => :milestones, :action => :show, :id => milestone, :project_id => milestone.project }, options
          end

          # Link to version
          def link_to_iteration(iteration, options = {})
            return '' unless iteration && iteration.is_a?(Iteration)
            link_to iteration.name, { :controller => :iterations, :action => :show, :id => iteration, :project_id => iteration.project }, options
          end
        end
      end
    end
  end
end
