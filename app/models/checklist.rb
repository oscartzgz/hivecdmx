# app/models/checklist.rb
module Checklist
  DATA = begin
    raw = YAML.load_file(Rails.root.join("config/checklist.yml"))
    deep_freeze = ->(obj) {
      case obj
      when Hash  then obj.each_value { |v| deep_freeze.call(v) }.freeze
      when Array then obj.each { |v| deep_freeze.call(v) }.freeze
      else            obj.freeze rescue obj
      end
    }
    deep_freeze.call(raw)
  end

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
