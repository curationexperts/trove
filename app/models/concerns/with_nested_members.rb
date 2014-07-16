module WithNestedMembers
  extend ActiveSupport::Concern

  # this sets all the members of a collection (images and collections)
  # any that are not provided are removed.
  def member_attributes=(members)
    members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
    self.member_ids = members.sort_by { |e| e['weight'] }.map { |e| e['id'] }
  end

  # this sets just the collection members of a collection.
  # any collection that is not provided is removed. Images members are preserved
  def collection_attributes=(members)
    members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
    assign_tree(make_tree(members))
  end

  # update the nested collections with attributes arranged in a tree structure.
  # @see make_tree
  def assign_tree(tree)
    nodes = tree.sort_by { |e| e['weight'] } 
    
    self.member_ids = noncollection_member_ids + nodes.map { |e| e['id'] } 
    nodes.each do |node|
      b = ActiveFedora::Base.find(node['id'])
      b.assign_tree node['children']
      b.save! #TODO We could move this save into an after_save hook.
    end
  end

  protected
    def noncollection_member_ids
      @noncollection_member_ids ||= begin
        return [] if member_ids.empty?
        query = [ActiveFedora::SolrService.construct_query_for_pids(member_ids.map(&:to_s)),
                 ActiveFedora::SolrService.construct_query_for_rel(has_model: TuftsImage.to_class_uri)].
                join(' AND ')
        ActiveFedora::SolrService.query(query, fl: 'id').map { |result| result['id'] }
      end
    end

    # Takes in a linked list with parent pointers and transforms it to a tree
    def make_tree(in_list, pid = self.pid)
      [].tap do |top_level|
        left_over = []
        # Categorize into top level, or not top level
        in_list.each do |node|
          if node['parent_page_id'].blank? || node['parent_page_id'] == pid
            top_level.unshift node
          else
            left_over.unshift node
          end
        end

        # For each of the top_level nodes make a subtree with the leftovers.
        top_level.each do |node|
          node['children'] = make_tree(left_over, node['id'])
        end
      end
    end
end
