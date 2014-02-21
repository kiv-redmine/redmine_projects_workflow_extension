class Milestone < ActiveRecord::Base
  unloadable

  # Belongs to project
  belongs_to :project

  # Has many issues
  has_many :issues

  # Safe attributes
  safe_attributes 'name', 'description', 'start_date', 'end_date', 'project_id'

  # Validates
  validates_presence_of :name, :start_date, :end_date
  validates_uniqueness_of :name, :scope => [ :project_id ]
end
