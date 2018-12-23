class SearchController < ApplicationController

  require 'will_paginate'

  def index
    @filterrific = initialize_filterrific(
      House,
      params[:filterrific],
      select_options: {
        sorted_by: House.options_for_sorted_by,
        with_name: House.options_for_select,
        with_address: House.options_for_select,
        with_rented: House.options_for_select
      },
      # persistence_id: 'shared_key',
      # default_filter_params: {},
      available_filters: [:with_name, :with_address, :with_rented],
      sanitize_params: true
    ) or return

    @houses = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

end
