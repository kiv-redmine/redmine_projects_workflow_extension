# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

namespace :burndown do
  desc "Generate for specific project\n\nOptions:\n\tproject=PROJECT   project name\n"
  task :generate => :environment do
    # Get options
    begin
      project = Project.find_by_identifier!(ENV['PROJECT'])
    rescue
     puts "Project with identifier: \"#{ENV['PROJECT']}\" not found!"
     return
    end

    # Information
    puts "Regenerating burndown chart data:\n"

    # Generate
    project_regenerator(project)
  end

  desc "Generate for all projects"
  task :generate_all => :environment do
    puts "Regenerating burndown chart data:\n"
    Project.all.each do |project|
      project_regenerator(project)
    end
  end

  def project_regenerator(project)
    # Log
    puts " - #{project.identifier}\n"

    # If empty error!
    unless project.get_start_date || project.get_end_date
      puts " - Error, you have to fill start or end project date!\n"
      return
    end

    # Remove all data
    project.burndown_records.destroy_all

    # Iterate by days!
    # 1) Changing estimated times
    # 2) TimeEntry
    (project.get_start_date...project.get_end_date).each do |day|
      BurndownRecord.update_by_project_and_day(project, day, true)
    end
  end
end
