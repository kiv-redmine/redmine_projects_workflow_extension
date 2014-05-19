# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module JournalDetailPatch
      def self.included(base)
        base.class_eval do
          after_create  :update_burndown_records
          after_destroy :update_burndown_records

          def update_burndown_records
            if prop_key == "estimated_hours" && project = journal.issue.try(:project)
              if old_value
                BurndownRecord.update_project_add_time(project, journal.created_on)
              else
                BurndownRecord.update_project_start(project)
              end
            end
          end
        end
      end
    end
  end
end
