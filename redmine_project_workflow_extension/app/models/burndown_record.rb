# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

class BurndownRecord < ActiveRecord::Base
  include Redmine::SafeAttributes

  # Belongs to project
  belongs_to :project

  # Safe attributes
  safe_attributes 'day', 'sub_time', 'add_time'

  # Update project start record!
  def self.update_project_start(project, log = false)
    # Update project start date
    project.update_total_estimated_time

    # Log
    if log
      puts "\tEstimated project time: #{project.total_estimated_time} hours"
    end
  end

  # Update add_time
  def self.update_project_add_time(project, date)
    # Get record
    record = get_record(project, date)

    # Start record? ( update estimated time)
    if date.to_date == project.start_date
      project.update_total_estimated_time
    end

    # Update add time
    record.add_time = project.get_add_time(date)
    record.save!
  end

  # Update sub_time
  def self.update_project_sub_time(project, date)
    # Get record
    record = get_record(project, date)

    # Start record? ( update estimated time)
    if date.to_date == project.start_date
      project.update_total_estimated_time
    end

    # Update sub_time
    record.sub_time = project.get_sub_time(date)
    record.save!
  end

  # Update sub and add time
  def self.update_project_day_time(project, date, log = false)
    # Get record
    record = get_record(project, date)

    # Update times
    record.sub_time = project.get_sub_time(date)
    record.add_time = project.get_add_time(date)

    # Save only valid records
    if record.sub_time != 0 || record.add_time != 0 || record.new_record? == false
      # Save record
      record.save!

      # Report
      if log
        puts "\t#{date} - +#{record.add_time}, -#{record.sub_time}"
      end
    end
  end

  # Get Record for specific date and project
  def self.get_record(project, date)
    # Find or create burndown record
    record = BurndownRecord.find(
      :first,
      :conditions => [ "project_id = ? AND day BETWEEN ? AND ? ", project.id, date.beginning_of_day, date.end_of_day ]
    )

    # If record not exists!
    unless record
      record = BurndownRecord.new(
        :project_id => project.id,
        :day => date,
        :sub_time => 0,
        :add_time => 0
      )
    end

    # Return record
    record
  end
end
