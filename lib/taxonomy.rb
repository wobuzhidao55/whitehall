module Taxonomy
  def self.education
    @education ||= begin
      filename = Rails.root + "lib/taxonomy/education.json"
      taxonomy = JSON.parse(File.read(filename))
      TreeNode.new(content_item: taxonomy)
    end
  end

  # TODO: move this to a gem, so we can use the same code in content tagger
  class TreeNode
    attr_reader :name, :content_item, :children
    attr_accessor :parent_node
    delegate :content_id, to: :content_item
    delegate :map, :each, to: :tree

    def initialize(content_item:, name_field: "title")
      @name = content_item[name_field]
      @content_item = content_item
      @children = []

      child_taxons = content_item["links"]["child_taxons"]

      if child_taxons.present?
        child_nodes = child_taxons.map do |child|
          TreeNode.new(name_field: name_field, content_item: child)
        end

        child_nodes.each do |child_node|
          self << child_node
        end
      end
    end

    def <<(child_node)
      child_node.parent_node = self
      @children << child_node
    end

    def tree
      return [self] if @children.empty?

      @children.each_with_object([self]) do |child, tree|
        tree.concat(child.tree)
      end
    end

    def count
      tree.count
    end

    def root?
      parent_node.nil?
    end

    def node_depth
      return 0 if root?
      1 + parent_node.node_depth
    end
  end

end
