# app/models/checklist.rb
module Checklist
  DATA = YAML.load_file(Rails.root.join("config/checklist.yml")).freeze

  def self.categories
    DATA["categories"]
  end

  def self.items_for(category_name)
    categories.find { |c| c["name"] == category_name }&.fetch("items", []) || []
  end

  def self.rooms
    DATA["rooms"]["floors"].flat_map do |floor|
      range = floor["range"]
      (range[0]..range[1]).map(&:to_s)
    end
  end

  def self.composite_key(room, category, item_name)
    "#{room}::#{category}::#{item_name}"
  end
end
