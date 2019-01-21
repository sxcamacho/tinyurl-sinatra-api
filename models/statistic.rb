class Statistic
    include Mongoid::Document
  
    field :tiny_id, type: String
    field :date, type: DateTime
  
    validates :tiny_id, presence: true
    validates :date, presence: true
  
    index({ tiny_id: 1 }, { unique: false, name: "statistics_tiny_id_index" })
    index({ date: 1 }, { unique: true, name: "statistics_stamp_index" })

    scope :find_by_tiny_id, -> (param_tiny_id) { where(tiny_id: param_tiny_id) }
    
    def self.aggregate_by_tiny_id(tiny_id)
      match_stage = {
        "$match" => { "tiny_id" => tiny_id }
      }
      group_stage = {
        "$group" => {
          "_id" => {
            "date" => { "$dateToString" => { "format" => "%Y-%m-%d", "date" => "$date" } }
          },
          "count" => { "$sum" => 1 }
        }
      }
      Statistic.collection.aggregate([match_stage, group_stage])
    end
  end