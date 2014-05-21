# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module GraphHelper
  # Print line chart
  def print_chart_line(array)
    array.map { |line| "[ #{line[0]}, #{line[1]} ]" }.join(', ')
  end

  # Print burndown
  def print_burn_down(array)
    # Total hours
    total_hours = 0

    # Return array
    data = []

    # Iterate
    array.each do |rec|
      total_hours = (total_hours + rec.add_time - rec.sub_time).to_f.round(2)
      data << " [ #{date_to_json(rec.day)}, #{total_hours} ] "
    end

    # Return
    data.join(', ').html_safe
  end

  # Print records
  def print_burn_up(array)
    # Total hours
    total_hours = 0

    # Return array
    data = []

    # Iterate
    array.each do |rec|
      total_hours = (total_hours - rec.add_time + rec.sub_time).to_f.round(2)
      data << " [ #{date_to_json(rec.day)}, #{total_hours} ] "
    end

    # Return
    data.join(', ').html_safe
  end
end
