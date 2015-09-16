class SearcherController < ApplicationController
  def index
    filter_term = params[:filter_term]
    search_term = params[:search_term]
    @search = Product.search do
      fulltext search_term do
        if filter_term == "brands"
          fields(:brand)
        elsif filter_term == "categories"
          fields(:category)
        elsif filter_term == "products"
          fields(:name)
        end
      end
    end
    @results = @search.results
  end
end
