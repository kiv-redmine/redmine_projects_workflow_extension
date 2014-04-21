# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
          # After save - update project record?
          after_save :update_burndown_records

          # If changed estimated_hours = fix in burndown chart
          def update_burndown_records
            # Search
            if issue && details.all.find { |d| d.prop_key == "estimated_hours" }
              # Create
              BurndownRecord.update_project_add_time(issue.project, created_on)
            end
          end
        end
      end
    end
  end
end
