class SearchController < ApplicationController
  def search_response
    @consultations = Consultation.search(params[:query], fields: [:title, :content, :category_name, :user_name], match: :word_middle).uniq
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "search/search_response", locals: { consultations: @consultations })
        ]
      end
    end
  end

  def search
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("search-form", partial: "search/search")
        ]
      end
    end
  end
end
