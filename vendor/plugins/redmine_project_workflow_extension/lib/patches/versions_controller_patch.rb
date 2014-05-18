# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>
module RedmineProjectWorkflowExtension
  module Patches
    module VersionsControllerPatch
      def self.included(base)
        base.class_eval do
          def index_with_advanced_workflow
            # Parse type (whitelist)
            if %w(versions milestones iterations).include? params[:roadmap_type]
              @roadmap_type = params[:roadmap_type]
            else
              @roadmap_type = "versions"
            end

            if @roadmap_type == "versions"
              # Call parent
              return index_without_advanced_workflow
            end

            # Fill data
            @trackers = @project.trackers.find(:all, :order => 'position')
            retrieve_selected_tracker_ids(@trackers, @trackers.select {|t| t.is_in_roadmap?})

            # With subproject parameter?
            @with_subprojects = params[:with_subprojects].nil? ? Setting.display_subprojects_issues? : (params[:with_subprojects] == '1')
            project_ids = @with_subprojects ? @project.self_and_descendants.collect(&:id) : [@project.id]


            if @roadmap_type == "milestones"
              # find milestones
              @milestones = @project.milestones || []
              @milestones += @project.rolled_up_milestones if @with_subprojects
              @milestones = @milestones.uniq.sort
              @milestones.reject! { |milestone| milestone.completed? } unless params[:completed]

              # Find issues
              @issues_by_milestone = {}
              unless @selected_tracker_ids.empty?
                @milestones.each do |milestone|
                  issues = milestone.issues.visible.find(:all,
                                                         :include => [:project, :status, :tracker, :priority],
                                                         :conditions => {:tracker_id => @selected_tracker_ids, :project_id => project_ids},
                                                         :order => "#{Project.table_name}.lft, #{Tracker.table_name}.position, #{Issue.table_name}.id")
                  @issues_by_milestone[milestone] = issues
                end
              end
              @milestones.reject! {|milestone| !project_ids.include?(milestone.project_id) && @issues_by_milestone[milestone].blank?}
            else
              # find iterations
              @iterations = @project.iterations || []
              @iterations += @project.rolled_up_iterations if @with_subprojects
              @iterations = @iterations.uniq.sort
              @iterations.reject! { |milestone| milestone.completed? } unless params[:completed]

              # Find issues!
              @issues_by_iteration = {}
              unless @selected_tracker_ids.empty?
                @iterations.each do |iteration|
                  issues = iteration.issues.visible.find(:all,
                                                         :include => [:project, :status, :tracker, :priority],
                                                         :conditions => {:tracker_id => @selected_tracker_ids, :project_id => project_ids},
                                                         :order => "#{Project.table_name}.lft, #{Tracker.table_name}.position, #{Issue.table_name}.id")
                  @issues_by_iteration[iteration] = issues
                end
              end
              @iterations.reject! {|iteration| !project_ids.include?(iteration.project_id) && @issues_by_iteration[iteration].blank?}
            end
          end

          alias_method_chain :index, :advanced_workflow
        end
      end
    end
  end
end
