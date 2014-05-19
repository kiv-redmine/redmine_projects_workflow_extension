# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module JournalPatch
      def self.included(base)
        base.class_eval do
          after_destroy :update_burndown_records

          def update_burndown_records
            if issue
              BurndownRecord.update_project_add_time(issue.project, created_on)
            end
          end
        end
      end
    end
  end
end
