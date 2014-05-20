# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

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
    iteration.start_date <=> start_date
  end

  # Is milestone completed?
  def completed?
    end_date && (end_date <= Date.today) && (open_issues_count == 0)
  end

  # Returns the total amount of open issues for this milestone.
  def open_issues_count
    load_issue_counts
    @open_issues_count
  end

  def closed_issues_count
    load_issue_counts
    @closed_issues_count
  end

  def issues_count
    load_issue_counts
    @issue_count
  end

  def completed_pourcent
    if issues_count == 0
      0
    elsif open_issues_count == 0
      100
    else
      issues_progress(false) + issues_progress(true)
    end
  end

  def closed_pourcent
    if issues_count == 0
      0
    else
      issues_progress(false)
    end
  end

  # Returns the total progress of open or closed issues.  The returned percentage takes into account
  # the amount of estimated time set for this version.
  #
  # Examples:
  # issues_progress(true)   => returns the progress percentage for open issues.
  # issues_progress(false)  => returns the progress percentage for closed issues.
  def issues_progress(open)
    @issues_progress ||= {}
    @issues_progress[open] ||= begin
      progress = 0
      if issues_count > 0
        ratio = open ? 'done_ratio' : 100
        done = issues.open(open).sum("COALESCE(estimated_hours, #{estimated_average}) * #{ratio}").to_f
        progress = done / (estimated_average * issues_count)
      end
      progress
    end
  end

  # Returns the average estimated time of assigned issues
  # or 1 if no issue has an estimated time
  # Used to weigth unestimated issues in progress calculation
  def estimated_average
    if @estimated_average.nil?
      average = issues.average(:estimated_hours).to_f
      if average == 0
        average = 1
      end
      @estimated_average = average
    end
    @estimated_average
  end


  private
    def load_issue_counts
      unless @issue_count
        @open_issues_count = 0
        @closed_issues_count = 0
        issues.count(:all, :group => :status).each do |status, count|
          if status.is_closed?
            @closed_issues_count += count
          else
            @open_issues_count += count
          end
        end
        @issue_count = @open_issues_count + @closed_issues_count
      end
    end

    def date_validation
      errors.add(:start_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:start_date]
      errors.add(:end_date, I18n.t("activerecord.errors.messages.not_a_date")) unless self[:end_date]

      if self[:start_date] && self[:end_date] && self[:start_date] > self[:end_date]
        errors.add(nil, I18n.t(:error_date_overleap))
      end
    end
end
