# Project Workflow Extension

## Informations

* This plugin is only for Redmine 1.3
* This plugin was developed as my semestral work for KIV/JET on
  University on West Bohemia (http://www.zcu.cz)
* More informations in features

## Features

* Add start date to project
* Add start and end date to versions
* Add milestones and iterations
* Set version, milestone and iteration required
* Show Milestones and Iterations in issue overview
* Grouping / Filtering by Milestone / Iteration
* Burndown and Issue status charts
* Rights settings for view charts, edit iterations or milestones
* Advanced roadmap - iterations/milestones/versions

## Reconstruction burndown data

There is two rake tasks for regenerate old data from project for
burndown.

*For one project:*

```ruby
RAILS_ENV=production rake burndown:generate PROJECT=project_identifier
```

*For all project:*

```ruby
RAILS_ENV=production rake burndown:generate_all
```

## Screenshots &amp; Features

### Better project overview

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/overview.png" alt="Project overview"  style="box-shadow: 5px 5px rgba(0, 0, 0, .5);" />

### Burndown chart
<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/burndown.png" alt="Burndown chart"  style="box-shadow: 5px 5px rgba(0, 0, 0, .5);" />

### Burnup chart
<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/burnup.png" alt="Burnup chart"  style="box-shadow: 5px 5px rgba(0, 0, 0, .5);" />

### Issue status
<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/issue_status.png" alt="Issue status"  style="box-shadow: 5px 5px rgba(0, 0, 0, .5);" />

### Advanced roadmap

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/roadmap.png" alt="Project roadmap"  style="box-shadow: 5px 5px rgba(0, 0, 0, .5);" />

### Project start &amp; end date

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/project.png" alt="Project start date" />

### New issue (required Version, Iteration and Milestone)

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/new_issue.png" alt="Project new issue" />

### Milestones and Iterations

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/milestones.png" alt="Project settings milestones" />

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/iterations.png" alt="Project settings iterations" />

### Grouping by iteration and milestones

<img src="https://raw.github.com/Strnadj/redmine13_project_workflow_extension/master/readme_data/grouping.png" alt="Project iterations grouping" />

## How to contribute?

1. Fork it!
2. Make your changes
3. Create pull-request with issue

Thanks Strnadj!
