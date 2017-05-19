module StaticPagesHelper
  def full_title(page_title = '')
    base_title = 'go.bath beta'
    if page_title.empty?
      base_title
    else
      base_title + ' | ' + page_title
    end
  end
end
