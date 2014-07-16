module WithNestedMembers
  extend ActiveSupport::Concern

  # TODO this is slow (loads every object, even TuftsImages) and could be optimized.
  def collection_members
    @collection_members ||= members.select { |member| member.is_a? self.class }
  end

  # TODO this is slow (loads every object, even TuftsImages) and could be optimized.
  def noncollection_members
    @noncollection_members ||= members.reject { |member| member.is_a? self.class }
  end

  def member_attributes=(members)
    members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
    self.member_ids = members.sort_by { |e| e['weight'] }.map { |e| e['id'] }
  end

  def collection_attributes=(members)
    members = members.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes } if members.is_a? Hash
    members = make_tree(members).sort_by { |e| e['weight'] } 
    
    self.member_ids = noncollection_members.map(&:id) + members.map { |e| e['id'] } 
    members.each do |node|
      b = ActiveFedora::Base.find(node['id'])
      b.collection_attributes = node['children']
      b.save! #TODO We could move this save into an after_save hook.
    end
  end

  protected

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
