<% js = escape_javascript(
  render(partial: 'houses/list', locals: { houses: @houses })
) %>
$("#filterrific_results").html("<%= js %>");
