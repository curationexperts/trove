# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document
  include Tufts::SolrDocument

  # @overriden To add more collection types
  def collection?
    ['CourseCollection', 'PersonalCollection'].include? self['active_fedora_model_ssi']
  end

  # @overriden so that the value is cached
  def to_model
    @model ||= if collection?
      m = ActiveFedora::Base.load_instance_from_solr(id, self)
      m.class == ActiveFedora::Base ? self : m
    else
      self
    end
  end

  delegate :parent_count, to: :to_model
end
