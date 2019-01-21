class StatisticSerializer
  def initialize(statistic)
    @statistic = statistic
  end

  def as_json(*)
    data = {
      date: @statistic[:_id][:date],
      count: @statistic[:count]
    }
    data
  end
end