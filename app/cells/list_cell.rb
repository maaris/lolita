class ListCell < Cell::Rails
  def display
    @list    = @opts[:list]
    render
  end

  def header
    render
  end

  def header_cell
    render
  end

  def body
    render
  end

  def row
    @record=@opts[:record]
    render
  end

  def body_cell
    render
  end

  def paginator
    render
  end
end
