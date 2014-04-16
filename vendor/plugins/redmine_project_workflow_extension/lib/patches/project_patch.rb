# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module RedmineProjectWorkflowExtension
  module Patches
    module ProjectPatch
       def self.included(base)
        base.class_eval do
          safe_attributes :start_date, :end_date

          # Validations - start_date is required
          validate :start_date_validation, :end_date_validation

          # Has many milestones and iterations
          has_many :milestones, :dependent => :destroy
          has_many :iterations, :dependent => :destroy

          # Include
          base.send(:include, InstanceMethods)
        end
       end

       module InstanceMethods
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
