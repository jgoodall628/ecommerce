class SearcherController < ApplicationController
  def index
   @search = Product.search do
     keywords params[:search_term]
   end
   @results = @search.results
 end
end
