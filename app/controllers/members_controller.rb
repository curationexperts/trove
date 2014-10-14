class MembersController < ApplicationController
  include Blacklight::SolrHelper
  include CuratedCollectionHelper

  before_filter :load_collection

  def show
    # Positions are retrieved from tufts_models, so they won't change if a
    # member is no longer displayed in tdil.
    # This makes it so we don't have to load every descendant member to see if it's
    # visible in tdil when determining positions, we can just count pids.
    position = params[:id].to_i
    member_ids = [nil] + @collection.flattened_member_ids.force
    doc = get_solr_response_for_doc_id(member_ids[position]).second
    @document = doc if doc['displays_ssim'].include?('tdil') && doc['object_state_ssi'] == 'A'

    @prev_position, @next_position = prev_and_next_positions(member_ids, position)

    if @document
      render 'catalog/show'
    else
      redirect_to @collection
    end
  end

  protected

    def prev_and_next_positions(member_ids, current_position)
      if current_position > 1
        _, prev_position = member_ids[0..(current_position - 1)].
          # add positions
          each_with_index.
          # reverse so we search backwards
          to_a.reverse.
          # find the closest visible neighbor
          find { |(pid, _)| visible_by_tdil?(pid) }
      end

      _, next_position = member_ids.
        # add positions
        each_with_index.
        # start looking after the current member
        drop(current_position + 1).
        # find the closest visible neighbor
        find { |(pid, _)| visible_by_tdil?(pid) }

      [prev_position, next_position]
    end

    def visible_by_tdil?(pid)
      doc = get_solr_response_for_doc_id(pid).second
      doc['displays_ssim'].include?('tdil') && doc['object_state_ssi'] == 'A'
    end

    def load_collection
      @collection = ActiveFedora::Base.find(params[:personal_collection_id] || params[:course_collection_id])
    end

    def _prefixes
      # This allows us to use the templates in catalog
      @_prefixes ||= super + ['catalog']
    end

    def blacklight_config
      CatalogController.blacklight_config
    end
end
