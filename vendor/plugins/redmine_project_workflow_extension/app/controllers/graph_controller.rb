# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

class GraphController < ApplicationController
  # Find project
  before_filter :find_project_by_project_id
  before_filter :authorize

  # Helper method
  helper_method :date_to_json

  # Show graphs
  def burndown
    # Get versions & iterations & milestones
    @versions = @project.versions.map { |version| {
      :from => date_to_json(version[:start_date]),
      :to   => date_to_json(version.due_date),
      :label => version.name,
      :id    => "version_#{version.name.underscore}",
      :color => "rgba(#{rand(255)}, #{rand(255)}, #{rand(255)}, .2)"
    } }

    @milestones = @project.milestones.map { |milestone| {
      :from => date_to_json(milestone[:start_date]),
      :to   => date_to_json(milestone[:end_date]),
      :label => milestone.name,
      :id    => "milestone_#{milestone.name.underscore}",
      :color => "rgba(#{rand(255)}, #{rand(255)}, #{rand(255)}, .2)"
    } }

    @iterations = @project.iterations.map { |iteration| {
      :from => date_to_json(iteration[:start_date]),
      :to   => date_to_json(iteration[:end_date]),
      :label => iteration.name,
      :id    => "iteration_#{iteration.name.underscore}",
      :color => "rgba(#{rand(255)}, #{rand(255)}, #{rand(255)}, .2)"
    } }

    # Start date
    @start_date = @project.get_start_date
    @end_date   = @project.get_end_date

    # Get total hours from init
    init_rec = @project.burndown_records.find(:first, :conditions => [ "init_project = ?", true ])

    # Create init rec
    unless init_rec
      BurndownRecord.update_project_start(@project)
      init_rec = @project.burndown_records.find(:first, :conditions => [ "init_project = ?", true ])
    end

    @total_hours = init_rec.add_time

    # Callculate straight line
    @ideal_line = []

    # Set start and end date to Working days!
    if @start_date.cwday >= 6
      # Skip to working days
      start_date = @start_date.advance(:days => (8 - @start_date.cwday))

      # Add start date point
      @ideal_line << [ date_to_json(date), @total_hours ]
    else
      start_date = @start_date
    end

    if @end_date.cwday >= 6
      end_date = @end_date.advance(:days => (8 - @end_date.cwday))
    else
      end_date = @end_date
    end

    @day_diff    = (end_date - start_date).to_i

    # Equasion for line!
    # y = mx+b
    # m = (y2-y1) / (x2 - x1)
    m = (- @total_hours * 1.0) / ( @day_diff * 1.0)

    # coefficients
    # b = y1 - m*x1
    # in this case is total hours => 0,800 -> b = 800 - m*0
    b = @total_hours * 1.0

    # So Y function is now...
    f = lambda { |x| m*x + b }

    # Date
    date = start_date

    # Add first date to project and start iteration
    @ideal_line << [ date_to_json(date), @total_hours ]

    # Get Friday! - 5 - monday = 4 :)
    date = date.advance(:days => (5 - date.cwday))

    # Start iteration
    while (date < @end_date) do
      # Get monday!
      monday = date.advance(:days => 3)

      # If monday is later than end date => 0
      if monday > @end_date
        hours = 0
      else
        hours = f.call((monday-start_date).to_i)
      end

      # Add to line week
      @ideal_line << [ date_to_json(date), hours.to_f.round(2) ]
      @ideal_line << [ date_to_json(monday), hours.to_f.round(2) ]

      # Next week!
      date = date.advance(:weeks => 1)
    end

    # Add ideal line
    @ideal_line << [ date_to_json(@end_date), 0 ]

    # Current line
    @current_line = @project.burndown_records
  end

  # Issue status
  def issue_status
    # Get all issues status (group by)
    status_group = @project.issues.count(:group => 'status_id')

    # Get all String statuses!
    statuses = {}
    IssueStatus.find(:all, :conditions => [ "id IN (?)", status_group.keys ]).each { |p| statuses[p.id] = p.name }

    # Prepare rows!
    @rows = status_group.map { |k,v| [ statuses[k], v] }.to_json
  end

  private

  def date_to_json(date)
    "Date.UTC(#{date.year}, #{date.month-1}, #{date.day})"
  end
end
