# Patches issue to add MILESTONE and ITERATIONS
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
        end
       end
    end
  end
end
