class GraphController < ApplicationController
  # Find project
  before_filter :find_project_by_project_id
  before_filter :authorize

  # Show graphs
  def burndown
    # Get versions
    @milestones = @project.milestones
    @iterations = @project.iterations

    # Prepare plot bands!
    @plotBands = []

    @project.versions.all.each do |version|
      @plotBands << {
        :from => "Date.UTC(#{version[:start_date].strftime("%Y, %m, %d")})",
        :to   => "Date.UTC(#{version.due_date.strftime("%Y, %m, %d")})",
        :label => version.name,
        :color => 'rgba(68, 170, 213, .2)'
      }
    end
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
end
