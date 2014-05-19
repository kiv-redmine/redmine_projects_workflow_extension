# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>
module RedmineProjectWorkflowExtension
  module Patches
    module QueriesHelperPatch
      def self.included(base)
        base.class_eval do
          def column_content_with_iterations_and_milestones(column, issue)
            value = column.value(issue)

            case value.class.name
            when 'Iteration'
              h(value.name)
            when 'Milestone'
              h(value.name)
            else
              column_content_without_iterations_and_milestones(column, issue)
            end
          end

          alias_method_chain :column_content, :iterations_and_milestones
        end
      end
    end
  end
end
