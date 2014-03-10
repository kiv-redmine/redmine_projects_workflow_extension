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
  validate :date_validation

  # Overload compare operator
  def <=>(iteration)
    iteration.start_date <=> iteration.start_date
  end

  private

    def date_validation
      errors.add(:start_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:start_date]
      errors.add(:end_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:end_date]

      if self[:start_date] && self[:end_date] && self[:start_date] > self[:end_date]
        errors.add(nil, I18n.t(:error_date_overleap))
      end
    end
end
