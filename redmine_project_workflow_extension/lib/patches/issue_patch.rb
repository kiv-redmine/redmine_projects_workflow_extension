# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module IssuePatch
       def self.included(base)
        base.class_eval do
          unloadable

          # Belongs to Milestone
          belongs_to :milestone

          # Belongs to iteration
          belongs_to :iteration

          # Add to safe attributes!
          safe_attributes 'milestone_id', 'iteration_id'

          # After create - update project times
          after_create :update_burndown_record
          after_destroy :update_burndown_record

          def update_burndown_record
            BurndownRecord.update_project_start(project) unless estimated_hours.blank?
          end
        end
      end
    end
  end
end
