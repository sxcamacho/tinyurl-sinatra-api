class TinyUrlSerializer
  def initialize(url, count)
    @tiny_url = url
    @count = count
  end

  def as_json(*)
    data = {
      url: @tiny_url.url,
      tiny_url: @tiny_url.tiny_url,
      tiny_id: @tiny_url.tiny_id,
      count: @count
    }
    data[:errors] = @tiny_url.errors if @tiny_url.errors.any?
    data
  end
end