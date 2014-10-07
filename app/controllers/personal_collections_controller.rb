class PersonalCollectionsController < CuratedCollectionsController
  rescue_from Tufts::ModelNotAsserted do
    redirect_to course_collection_path(params[:id])
  end

  def index
    authorize! :index, PersonalCollection
    @solr_response = build_solr_response
  end

  protected

  def switch_type_actor
    SwitchToCourseCollectionActor.new(@curated_collection)
  end

  private

  def build_solr_response
    Blacklight::SolrResponse.new(solr_result, solr_parameters, solr_document_model: PersonalCollectionSolrProxy)
  end

  def solr_result
    ActiveFedora::SolrService.instance.conn.
      send_and_receive(blacklight_config.solr_path, params: solr_parameters)
  end

  def solr_parameters
    @params ||= {q: 'is_root_bsi:true', rows: 10, sort: 'title_si asc'}.tap do |solr_parameters|
      solr_parameters[:start] = solr_parameters[:rows] * (params[:page].to_i - 1) if params[:page].to_i > 0
      solr_parameters[:fq] = "has_model_ssim:\"#{PersonalCollection.to_class_uri}\""
    end
  end

end
