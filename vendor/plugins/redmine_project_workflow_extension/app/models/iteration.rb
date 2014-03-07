class Iteration < ActiveRecord::Base
  include Redmine::SafeAttributes

  # Belongs to project
  belongs_to :project

  # Has many issues
  has_many :issues

  # Safe attributes
  safe_attributes 'name', 'description', 'start_date', 'end_date', 'project_id'

  # Validates
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :project_id ]
  validates_presence_of :start_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => false
  validates_presence_of :end_date, :with => /^\d{4}-\d{2}-\d{2}$/, :message => :not_a_date, :allow_nil => false
end
