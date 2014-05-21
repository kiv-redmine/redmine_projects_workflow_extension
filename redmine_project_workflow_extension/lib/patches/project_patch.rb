# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module ProjectPatch
       def self.included(base)
        base.class_eval do
          safe_attributes :start_date, :end_date, :total_estimated_time

          # Validations - start_date is required
          validate :start_date_validation, :end_date_validation

          # Has many milestones and iterations
          has_many :milestones, :dependent => :destroy
          has_many :iterations, :dependent => :destroy

          # Burndown charts - sort by DAY ascending!
          has_many :burndown_records, :order => 'day ASC'

          # Include
          base.send(:include, InstanceMethods)
        end
       end

      module InstanceMethods
        def rolled_up_milestones
          @rolled_up_milestones ||=
            Milestone.scoped(:include => :project,
                     :conditions => ["#{Project.table_name}.lft >= ? AND #{Project.table_name}.rgt <= ? AND #{Project.table_name}.status = #{::Project::STATUS_ACTIVE}", lft, rgt])
        end

        def rolled_up_iterations
          @rolled_up_iterations ||=
            Iteration.scoped(:include => :project,
                     :conditions => ["#{Project.table_name}.lft >= ? AND #{Project.table_name}.rgt <= ? AND #{Project.table_name}.status = #{::Project::STATUS_ACTIVE}", lft, rgt])
        end

        def get_sub_time(date)
          TimeEntry.sum(:hours, :conditions => [ "project_id = ? AND spent_on = ?", self.id, date ]).to_f.round(3)
        end

        def get_add_time(date)
          JournalDetail.find(
            :first,
            :select => "SUM(#{JournalDetail.table_name}.value - #{JournalDetail.table_name}.old_value) AS diff",
            :joins => "
              INNER JOIN #{Journal.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id
              INNER JOIN #{Issue.table_name} ON #{Issue.table_name}.id = #{Journal.table_name}.journalized_id",
            :conditions => [
              "#{Journal.table_name}.journalized_type = ? AND
               #{JournalDetail.table_name}.prop_key = ? AND
               #{JournalDetail.table_name}.old_value IS NOT NULL AND
               #{Issue.table_name}.project_id = ? AND
               #{Journal.table_name}.created_on BETWEEN ? AND ?",
              "Issue",
              "estimated_hours",
              self.id,
              date.beginning_of_day,
              date.end_of_day
            ]
          ).try(:diff).to_f.round(3)
        end

        # Update total estimated time
        def update_total_estimated_time
          update_attributes(:total_estimated_time => get_total_time)
        end

        # Get total time
        def get_total_time
          # Count total time!
          total_time = 0

          # Iterate through project
          issues.find(:all, :conditions => [ " estimated_hours IS NOT NULL" ]).each do |issue|
            # Save estimated hours
            estimated_hours = issue.estimated_hours

            # Search in journal (you can again destroy estimated hours..)
            journal = issue.journals.find(:first, :joins => :details, :conditions => ["journal_details.prop_key = ? AND journal_details.old_value IS NULL AND journal_details.value IS NOT NULL", "estimated_hours"], :order => "created_on ASC")

            # If journal exist estimated_time can be different
            if journal
              estimated_hours = journal.details.all.find { |a| a.prop_key == "estimated_hours" }.value.to_f
            end

            # Update
            total_time = total_time + estimated_hours
          end

          total_time
        end

        # Get start date and end date in DateTime class
        def get_start_date
          @start_date ||= self[:start_date].is_a?(Time) ? self[:start_date].to_datetime : self[:start_date]
        end

        def get_end_date
          @end_date ||= self[:end_date].is_a?(Time) ? self[:end_date].to_datetime : self[:end_date]
        end

        # Start date validation - workaround - possible ISSUE in redmine safe_attributes (datetime) deprecated version
        def start_date_validation
          errors.add(:start_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:start_date]
        end

        def end_date_validation
          # Date not present
          errors.add(:end_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:end_date]

          # Start date & end date need to be same datetype!
          if self[:start_date]
            start_date = (self[:start_date].is_a?(Time)) ? self[:start_date].to_datetime : self[:start_date]
          end

          if self[:end_date]
            end_date = (self[:end_date].is_a?(Time)) ? self[:end_date].to_datetime : self[:end_date]
          end

          # End date is GT
          if start_date && end_date && start_date > end_date
            errors.add(nil, I18n.t(:error_date_overleap))
          end
        end
      end
    end
  end
end
