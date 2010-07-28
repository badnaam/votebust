class GraphsController < ApplicationController
  def gender_graph
      vt = VoteTopic.find_for_graphs(params[:id])
      render :text => vt.make_flash_gender_graph_stacked
  end

  def age_graph
      vt = VoteTopic.find_for_graphs(params[:id])
      render :text => vt.make_flash_age_graph_stacked
  end
  def pie_graph
      vt = VoteTopic.find_for_graphs(params[:id])
      render :text => vt.make_flash_pie_graph(false)
  end

end
