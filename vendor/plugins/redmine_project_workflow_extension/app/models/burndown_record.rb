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
    # Start date
    update_by_project_and_day(project, project.get_start_date, log)
  end

  def self.update_project_add_time(project, date)
    # Get record
    record = get_record(project, date)

    # If record is init_project - use update_by_project_and_day!
    if record.init_project
      update_by_project_and_day(project, date)
    else
      record.update_attributes(:add_time => project.get_add_time(date))
    end
  end

  def self.update_project_sub_time(project, date)
    # Get record
    record = get_record(project, date)

    # If record is init_project - use update_by_project_and_day!
    if record.init_project
      update_by_project_and_day(project, date)
    else
      record.update_attributes(:sub_time => project.get_sub_time(date))
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

    # Init
    record.init_project = date.to_date == project.get_start_date

    # Return record
    record
  end

  # Create burndown record from project and day
  def self.update_by_project_and_day(project, date, log = false)
    record = get_record(project, date)

    # If date is start_date => init!
    if record.init_project
      total_time = project.get_total_time

      # Log
      if log
        puts "   - Total hours: #{total_time}\n"
        puts "   - Creating init project record\n"
      end

      # Save record
      record.init_project = true
      record.add_time = total_time
      record.sub_time = 0
    end

    # Count time entries!
    sub_time = project.get_sub_time(date)

    # Update records
    add_time = project.get_add_time(date)

    # New record?
    if record.new_record? && !record.init_project && add_time == 0 && sub_time == 0
      return
    end

    # Save data
    if record.init_project
      record.add_time = record.add_time + add_time
    else
      record.add_time = add_time
    end
    record.sub_time = sub_time
    record.save!

    if log
      puts "     - #{date.strftime("%Y-%m-%d")} (add: #{add_time}, sub: #{sub_time})\n"
    end
  end
end
