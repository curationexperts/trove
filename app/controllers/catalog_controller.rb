# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior

  before_filter :allow_only_published_objects, only: [:show]

  CatalogController.solr_search_params_logic += [:only_displays_in_trove, :only_images_and_collections,
    :exclude_root_collection, :exclude_soft_deleted, :only_published_objects]

  configure_blacklight do |config|
    config.view.delete(:slideshow)
    config.default_solr_params = {
      :qt => 'search',
      :rows => 10,
      :qf => 'id creator_tesim title_tesim subject_tesim description_tesim identifier_tesim alternative_tesim contributor_tesim abstract_tesim toc_tesim publisher_tesim source_tesim date_tesim date_created_tesim date_created_formatted_tesim date_copyrighted_tesim date_submitted_tesim date_accepted_tesim date_issued_tesim date_available_tesim date_modified_tesim language_tesim type_tesim format_tesim extent_tesim medium_tesim persname_tesim corpname_tesim geogname_tesim genre_tesim provenance_tesim rights_tesim access_rights_tesim rights_holder_tesim license_tesim replaces_tesim isReplacedBy_tesim hasFormat_tesim isFormatOf_tesim hasPart_tesim isPartOf_tesim accrualPolicy_tesim audience_tesim references_tesim spatial_tesim bibliographic_citation_tesim temporal_tesim funder_tesim resolution_tesim bitdepth_tesim colorspace_tesim filesize_tesim steward_tesim name_tesim comment_tesim retentionPeriod_tesim displays_ssi embargo_tesim status_tesim startDate_tesim expDate_tesim qrStatus_tesim rejectionReason_tesim note_tesim'
    }

    config.show.partials = [:show]

    # solr field configuration for search results/index views
    config.index.title_field = 'title_tesim'
    config.index.display_type_field = 'has_model_ssim'

    config.index.thumbnail_method = :thumbnail_tag

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _tsimed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field solr_name('names', :facetable), :label => 'Names', :limit => 7
    config.add_facet_field solr_name('year', :facetable), :label => 'Year', :limit => 7
    config.add_facet_field solr_name('subject', :facetable), :label => 'Subject', :limit => 7

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.default_solr_params[:'facet.field'] = config.facet_fields.keys
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys


    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name('description', :stored_searchable, type: :string), label: 'Description'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name('title', :stored_searchable, type: :string), label: 'Title'
    config.add_show_field solr_name('creator', :stored_searchable, type: :string), label: 'Creator'
    config.add_show_field solr_name('contributor', :stored_searchable, type: :string), label: 'Contributor'
    config.add_show_field solr_name('date_created_formatted', :stored_searchable, type: :string), label: 'Date'
    config.add_show_field solr_name('description', :stored_searchable, type: :string), label: 'Description'
    config.add_show_field solr_name('spatial', :stored_searchable), label: 'Location depicted'
    config.add_show_field solr_name('temporal', :stored_searchable), label: 'Time period'
    config.add_show_field solr_name('genre', :stored_searchable), label: 'Genre'
    config.add_show_field solr_name('subject', :stored_searchable), label: 'Subject'



    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', :label => 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => 'title_tesim',
        :pf => 'title_tesim'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
#    config.add_search_field('subject') do |field|
#      field.qt = 'search'
#      field.solr_local_parameters = {
#        :qf => '$subject_qf',
#        :pf => '$subject_pf'
#      }
#    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, system_create_dtsi desc, title_si asc', :label => 'Relevance'
    config.add_sort_field 'system_create_dtsi desc, title_si asc', :label => 'Date Added'
    config.add_sort_field 'creator_si asc, title_si asc', :label => 'Creator'
    config.add_sort_field 'title_si asc, system_create_dtsi desc', :label => 'Title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  end

  def index
    @root_collection = CourseCollectionSolrProxy.root
    @my_collection = current_user.personal_collection_proxy

    # record preference for view type. Remove when we get:
    # https://github.com/projectblacklight/blacklight/pull/982
    session[:preferred_view] = params[:view] if params[:view]
    params[:view] ||= session[:preferred_view]
    super
  end


  def add_to_collection
    get_solr_response_for_doc_id(params[:id])
    if ActiveFedora::Base.exists?(params[:collection_id])
      collection = ActiveFedora::Base.find(params[:collection_id])
      authorize! :update, collection
      collection.member_ids << @document.id
    end
    if collection.present? && collection.save
      redirect_to catalog_path(@document.id)
    else
      flash.now[:error] = "We were unable to add this to the collection"
      render :show
    end
  end

protected

  def allow_only_published_objects
    not_found unless PidUtils.published?(params[:id])
  end

  def only_published_objects(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "id:#{PidUtils.published_namespace}*"
  end

  def only_images_and_collections(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "has_model_ssim:(\"#{TuftsImage.to_class_uri}\" OR \"#{CourseCollection.to_class_uri}\")"
  end

  def exclude_root_collection(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-id:\"#{CourseCollection::ROOT_PID}\""
  end

  def only_displays_in_trove(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "displays_ssim:trove"
  end

  def exclude_soft_deleted(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "NOT #{ActiveFedora::SolrService.solr_name("object_state", :stored_sortable)}:\"D\""
  end

  # Override method from blacklight to check for 'trove' display
  def get_solr_response_for_doc_id(id=nil, extra_controller_params={})
    @response, @document = super
    unless @document['displays_ssim'] && @document['displays_ssim'].include?('trove')
      raise Hydra::AccessDenied.new("You do not have sufficient access privileges to read this document.", :read, params[:id])
    end
    [@response, @document]
  end

end
