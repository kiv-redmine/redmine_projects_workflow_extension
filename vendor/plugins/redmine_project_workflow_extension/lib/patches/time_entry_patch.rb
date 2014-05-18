# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module TimeEntryPatch
      def self.included(base)
        base.class_eval do
          # After sav update burndown records
          after_save :update_burndown_record
          after_destroy :update_burndown_record

          # Validate estimated hours time
          validate :issue_estimated_time

          def issue_estimated_time
            errors.add :hours, l(:error_issue_estimated_hours_exceeded) if (issue.estimated_hours) < (issue.spent_hours + hours)
          end

          # Update sub_time records
          def update_burndown_record
            BurndownRecord.update_project_sub_time(project, spent_on)
          end
        end
      end
    end
  end
end
