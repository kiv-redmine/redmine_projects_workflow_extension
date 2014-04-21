# encoding: utf-8

# Part of Redmine Project Workflow Extension - 1.3 plugin
# author: strnadj <jan.strnadek@gmail.com>

module GraphHelper
  # Print line chart
  def print_chart_line(array)
    array.map { |line| "[ #{line[0]}, #{line[1]} ]" }.join(', ')
  end

  # Print plot band
  def print_plot_bands(array)
    "{ from: #{object[:from]}, to: #{object[:to]}, label: \"#{object[:label]}\", color: \"#{object[:color]}\" }"
  end

  def print_remove_plot_bands(chart, array)
    data = ""

    # It
    array.each do |item|
      data << "#{chart}.xAxis[0].removePlotBand('#{item[:id]}');"
    end

    # Return
    data.html_safe
  end

  def print_records(array)
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

  def print_create_plot_bands(chart, array)
    # Prepare data
    data = ""

    # Each item
    array.each do |item|
      data << "#{chart}.xAxis[0].addPlotBand({ " +
                "from: #{item[:from]}, to: #{item[:to]}, id: \"#{item[:id]}\"," +
                "color: \"#{item[:color]}\", " +
                "events: { mouseover: function (e) { displayTooltip('#{item[:label]}', this.svgElem.d.split(' ')[1] + this.svgElem.d.split(' ')[0]); }, mouseout: hideTooltip }" +
      "});"
    end

    # Return
    data.html_safe
  end
end
