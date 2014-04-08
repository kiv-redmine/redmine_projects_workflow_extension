class GraphController < ApplicationController
  # Find project
  before_filter :find_project_by_project_id

  # Show graphs
  def burndown

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
