class CollectionSolrProxy

  attr_reader :id

  def initialize(attrs)
    @id = attrs[:id]
    @properties = { title: attrs[:title] } if attrs[:title]
    @loaded = false
  end

  def collection_members
    @collection_members ||= begin
      return [] if member_ids.blank?
      query = ['(' + ActiveFedora::SolrService.construct_query_for_pids(member_ids) + ')',
               ActiveFedora::SolrService.construct_query_for_rel(has_model: klass.to_class_uri)].
              join(' AND ')
      # TODO could we load more fields here?
      member_results = ActiveFedora::SolrService.query(query, fl: 'id title')
      member_results.map { |result| self.class.new(id: result['id']) }
    end
  end

  def exists?
    @loaded || (properties && @loaded)
  end

  # This is used by form_for to determine whether to use :patch or :post as the method
  def persisted?
    exists?
  end

  def == other
    other.class == self.class && id == other.id
  end

  def title
    properties[:title]
  end

  def member_ids
    properties[:member_ids]
  end

  def klass 
    properties[:klass]
  end

  def to_param
    id
  end

  def to_key
    [id]
  end

  private
    def properties
      @properties ||= fetch_properties
    end

    def fetch_properties
      query = ActiveFedora::SolrService.raw_query( SOLR_DOCUMENT_ID, @id)
      result = ActiveFedora::SolrService.query(query, fl: 'id member_ids_ssim title_tesim has_model_ssim').first
      return {} if result.nil?
      @loaded = true
      result_to_properties(result)
    end

    def result_to_properties(result)
      {
        member_ids: result['member_ids_ssim'],
        klass:      ActiveFedora::Model.from_class_uri(result['has_model_ssim'].first),
        title:      result['title_tesim'].first
      }
    end
end
