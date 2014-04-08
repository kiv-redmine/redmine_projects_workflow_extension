# Add milestone and iterations to query!
module RedmineProjectWorkflowExtension
  module Patches
    module QueryPatch
       def self.included(base)
        base.class_eval do
          def available_filters_with_iterations_and_milestones
            # Get available filters
            @available_filters = available_filters_without_iterations_and_milestones

            # Contains available filters already
            if project
              milestones = project.milestones
              iterations = project.iterations
            else
              milestones = Milestone.all
              iterations = Iteration.all
            end

            # Add filters
            unless @available_filters.has_key?("milestone_id")
              @available_filters["milestone_id"] = {
                :type => :list_optional,
                :order => 8,
                :values => milestones.collect { |m| ["#{m.project.name} - #{m.name}", m.id.to_s] }
              }
            end

            # Contains available filters already
            unless @available_filters.has_key?("iteration_id")
              @available_filters["iteration_id"] = {
                :type => :list_optional,
                :order => 9,
                :values => iterations.collect { |m| ["#{m.project.name} - #{m.name}", m.id.to_s] }
              }
            end

            # Return
            @available_filters
          end
          alias_method_chain :available_filters, :iterations_and_milestones

          # Add to available columns
          def available_columns_with_iterations_and_milestones
            # Return
            return @available_columns_milestones if @available_columns_milestones

            # Get
            @available_columns_milestones = available_columns_without_iterations_and_milestones

            # Add variables
            @available_columns_milestones << QueryColumn.new(:milestone, :sortable => "#{Milestone.table_name}.name", :groupable => true)
            @available_columns_milestones << QueryColumn.new(:iteration, :sortable => "#{Iteration.table_name}.name", :groupable => true)

            # Return
            @available_columns_milestones
          end
          alias_method_chain :available_columns, :iterations_and_milestones

          # Returns the issues
          # Valid options are :order, :offset, :limit, :include, :conditions
          def issues(options={})
            order_option = [group_by_sort_order, options[:order]].reject {|s| s.blank?}.join(',')
            order_option = nil if order_option.blank?
            joins = (order_option && order_option.include?('authors')) ? "LEFT OUTER JOIN users authors ON authors.id = #{Issue.table_name}.author_id" : nil

            Issue.visible.scoped(:conditions => options[:conditions]).find :all, :include => ([:status, :project, :milestone, :iteration] + (options[:include] || [])).uniq,
                             :conditions => statement,
                             :order => order_option,
                             :joins => joins,
                             :limit  => options[:limit],
                             :offset => options[:offset]
          rescue ::ActiveRecord::StatementInvalid => e
            raise ::ActiveRecord::StatementInvalid.new(e.message)
          end
        end
       end
    end
  end
end
