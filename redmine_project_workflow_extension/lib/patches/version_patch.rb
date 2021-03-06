# Patches issue to add MILESTONE and ITERATIONS
module RedmineProjectWorkflowExtension
  module Patches
    module VersionPatch
      def self.included(base)
        base.class_eval do
          # Add to safe attributes!
          safe_attributes 'start_date'

          # Validations
          validate :date_validations

          # INstance methods
          base.send(:include, InstanceMethods)
        end
      end

      module InstanceMethods
        def date_validations
          errors.add(:start_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:start_date]
          errors.add(:effective_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:effective_date]

          if self[:start_date] && self[:effective_date] && self[:start_date] > self[:effective_date]
            errors.add(nil, I18n.t(:error_date_overleap))
          end
        end

        # Issues
        def issues
          fixed_issues
        end

        # Weird behaviour
        def start_date
          self[:start_date]
        end
      end
    end
  end
end
