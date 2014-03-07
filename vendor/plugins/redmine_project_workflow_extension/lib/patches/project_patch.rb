# Patches to add start_date to Projects
module RedmineProjectWorkflowExtension
  module Patches
    module ProjectPatch
       def self.included(base)
        base.class_eval do
          safe_attributes :start_date

          # Validations - start_date is required
          validate :start_date_validation

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
       end
    end
  end
end
