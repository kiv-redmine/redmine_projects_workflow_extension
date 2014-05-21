# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

class GraphController < ApplicationController
  # Find project
  before_filter :find_project_for_graph
  before_filter :authorize

  # Helper method
  helper_method :date_to_json

  # Fill version and authorization
  before_filter :apply_filters, :only => [ :burndown, :burnup ]

  # Show on Xaxis plot bands
  def show_plot_band
    if params[:type] == 'version'
      if params[:id] == 'all'
        @versions = @project.versions
      else
        @versions = Array.wrap(Version.find(params[:id]))
      end

      @array = @versions.map { |version| {
        :from => date_to_json(version[:start_date]),
        :to   => date_to_json(version.due_date),
        :label => version.name,
        :id    => version.id,
        :color => "rgba(#{rand(255)}, #{rand(255)}, #{rand(255)}, .2)"
      }}
    elsif params[:type] == 'milestone'
      if params[:id] == 'all'
        @milestones = @project.milestones
      else
        @milestones = Array.wrap(Milestone.find_by_id_and_project_id(params[:id], @project.id))
      end

      @array = @milestones.map { |milestone| {
        :from => date_to_json(milestone[:start_date]),
        :to   => date_to_json(milestone[:end_date]),
        :label => milestone.name,
        :id    => milestone.id,
        :color => "rgba(#{rand(255)}, #{rand(255)}, #{rand(255)}, .2)"
      }}
    else
      if params[:id] == 'all'
        @iterations = @project.iterations
      else
        @iterations = Array.wrap(Iteration.find_by_id_and_project_id(params[:id], @project.id))
      end

      @array = @iterations.map { |iteration| {
        :from => date_to_json(iteration[:start_date]),
        :to   => date_to_json(iteration[:end_date]),
        :label => iteration.name,
        :id    => iteration.id,
        :color => "rgba(#{rand(255)}, #{rand(255)}, #{rand(255)}, .2)"
      }}

    end
  end

  # Show BurnUP
  def burnup
    # Project filter
    if @filter_by == 'all'
      # Project total hours
      total_hours = @project.total_estimated_time

      # Current line  burndown records)
      @current_line = @project.burndown_records

      # We have to add total hours to first record or create it!
      first_rec = @current_line.first

      # First not exists or date is greather than start date?
      if first_rec == nil || first_rec.day.to_date != @project.get_start_date
        # Create new
        rec = BurndownRecord.new(:day => @project.get_start_date, :sub_time => 0, :add_time => 0)

        # Add on first place of current line
        @current_line.insert(0, rec)
      end

      # Find project ideal line always!
      @ideal_line = generate_line(0, total_hours, @project.get_start_date, @project.get_end_date)
    else
      count_chart_for_project(@project, @data_obj, @condition, @start_date, @end_date)
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Show graphs
  def burndown
    # Project filter
    if @filter_by == 'all'
      # Project total hours
      total_hours = @project.total_estimated_time

      # Current line  burndown records)
      @current_line = @project.burndown_records

      # We have to add total hours to first record or create it!
      first_rec = @current_line.first

      # First not exists or date is greather than start date?
      if first_rec == nil || first_rec.day.to_date != @project.get_start_date
        # Create new
        rec = BurndownRecord.new(:day => @project.get_start_date, :sub_time => 0, :add_time => total_hours)

        # Add on first place of current line
        @current_line.insert(0, rec)
      else
        first_rec.add_time = first_rec.add_time + total_hours
      end

      # Find project ideal line always!
      @ideal_line = generate_line(total_hours, 0, @project.get_start_date, @project.get_end_date)
    else
      count_chart_for_project(@project, @data_obj, @condition, @start_date, @end_date, true)
    end
  rescue ActiveRecord::RecordNotFound
    render_404
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

  def apply_filters
    # Load milestones versions and iterations
    @milestones = @project.milestones
    @versions   = @project.versions
    @iterations = @project.iterations

    # Find by parameters
    @filter_by = params[:filter_by] || 'all'
    if @filter_by == 'version'
      # Version
      version = Version.find_by_id_and_project_id(params[:filter_by_version_id], @project.id)
      @start_date = version[:start_date]
      @end_date   = version.due_date
      @data_obj   = version
      @condition   = 'fixed_version_id'
    elsif @filter_by == 'milestone'
      # Milestone
      milestone = Milestone.find_by_id_and_project_id(params[:filter_by_milestone_id], @project.id)
      @start_date = milestone[:start_date]
      @end_date   = milestone[:end_date]
      @data_obj   = milestone
      @condition   = 'milestone_id'
    elsif @filter_by == 'iteration'
      # Iteration
      iteration = Iteration.find_by_id_and_project_id(params[:filter_by_iteration_id], @project.id)
      @start_date = iteration[:start_date]
      @end_date   = iteration[:end_date]
      @data_obj   = iteration
      @condition   = 'iteration_id'
    else
      # Project
      @start_date = @project.get_start_date
    end
  end

  def count_chart_for_project(project, data_obj, condition, start_date, end_date, burndown = false)
    # Sum total hours
    @total_hours = 0

    # Find journal records belongs to project in selected time
    changed_issues = Issue.find(:all, :conditions => { :'journals.created_on' => (start_date..end_date) }, :joins => :journals)

    # Count total hours
    data_obj.issues.find(:all, :conditions => [ "estimated_hours IS NOT NULL" ]).each do |issue|
      # Save estimated hours
      estimated_hours = issue.estimated_hours

      # Search in journal (you can again destroy estimated hours..)
      journal = issue.journals.find(:first, :joins => :details, :conditions => ["journal_details.prop_key = ? AND journal_details.old_value IS NULL AND journal_details.value IS NOT NULL", "estimated_hours"], :order => "created_on ASC")

      # If journal exist estimated_time can be different
      if journal
        estimated_hours = journal.details.all.find { |a| a.prop_key == "estimated_hours" }.value.to_f
      end

      # Update
      @total_hours = @total_hours + estimated_hours
    end

    # Prepare ideal line (burn up / down switch from-to)
    if burndown
      @ideal_line = generate_line(@total_hours, 0, start_date, end_date)
    else
      @ideal_line = generate_line(0, @total_hours, start_date, end_date)
    end

    # Right line
    @current_line = []

    # Day, by day create records
    (start_date..end_date).each do |date|
      # Temporary record
      rec = BurndownRecord.new(:day => date, :sub_time => 0, :add_time => 0)

      # Sub time
      rec.add_time = JournalDetail.find(
            :first,
            :select => "SUM(#{JournalDetail.table_name}.value - #{JournalDetail.table_name}.old_value) AS diff",
            :joins => "
              INNER JOIN #{Journal.table_name} ON #{JournalDetail.table_name}.journal_id = #{Journal.table_name}.id
              INNER JOIN #{Issue.table_name} ON #{Issue.table_name}.id = #{Journal.table_name}.journalized_id",
            :conditions => [
              "#{Journal.table_name}.journalized_type = ? AND
               #{JournalDetail.table_name}.prop_key = ? AND
               #{JournalDetail.table_name}.old_value IS NOT NULL AND
               #{Issue.table_name}.project_id = ? AND
               #{Issue.table_name}.#{condition} = ? AND
               #{Journal.table_name}.created_on BETWEEN ? AND ?",
              "Issue",
              "estimated_hours",
              @project.id,
              data_obj.id,
              date.beginning_of_day,
              date.end_of_day
            ]
          ).try(:diff).to_f.round(3)

      # If BURNdown first item needs to have total ++
      if @current_line.count == 0 && burndown
        rec.add_time = rec.add_time + @total_hours
      end

      rec.sub_time = TimeEntry.sum(
                        :hours,
                        :joins => "INNER JOIN #{Issue.table_name} ON #{Issue.table_name}.id = #{TimeEntry.table_name}.issue_id",
                        :conditions => [
                          "#{TimeEntry.table_name}.project_id = ? AND
                          spent_on = ? AND
                          #{Issue.table_name}.#{condition} = ?",
                          @project.id,
                          date,
                          data_obj.id
                        ]).to_f.round(3)

      # Add to record
      if rec.add_time > 0 || rec.sub_time > 0 || @current_line.count == 0
        @current_line << rec
      end
    end
  end

  # Generate Line without weekends
  def generate_line(from, to, start_date, end_date)
    # Line points
    lines = []

    # Set start and end date to Working days!
    if start_date.cwday >= 6
      # Add official start date point
      lines << [ date_to_json(start_date), from ]

      # Skip to working days
      start_date = start_date.advance(:days => (8 - start_date.cwday))
    end

    # End day
    if end_date.cwday >= 6
      end_date = end_date.advance(:days => (8 - end_date.cwday))
    end

    # Total number of dates!
    day_diff = (end_date - start_date).to_i

    # Compute equasion
    # y = mx+b
    # m = (y2-y1) / (x2 - x1)
    m = (to * 1.0 - from) / (day_diff * 1.0)

    # Coefficient Y
    # b = y1 - m*x1
    b = from * 1.0

    # So Y function is now...
    f = lambda { |x| m*x + b }

    # Date
    date = start_date

    # Add first date to project and start iteration
    lines << [ date_to_json(date), from ]

    # Get Friday! - 5 - monday = 4 :)
    date = date.advance(:days => (5 - date.cwday))

    # Start iteration
    while (date < end_date) do
      # Get monday!
      monday = date.advance(:days => 3)

      # If monday is later than end date => 0
      if monday > end_date
        hours = to
        #Start date is friday!
      elsif date == start_date
        hours = from
      else
        hours = f.call((monday-start_date).to_i)
      end

      # Add to line week
      lines << [ date_to_json(date), hours.to_f.round(2) ]
      lines << [ date_to_json(monday), hours.to_f.round(2) ]

      # Next week!
      date = date.advance(:weeks => 1)
    end

    # Add ideal line
    lines << [ date_to_json(end_date), to ]

    # Return
    lines
  end

  # Find project of id params[:project_id]
  def find_project_for_graph
    @project = Project.find(params[:project_id], :include => [:versions, :milestones, :iterations])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Convert datetime to JSON
  def date_to_json(date)
    "Date.UTC(#{date.year}, #{date.month-1}, #{date.day})"
  end
end
