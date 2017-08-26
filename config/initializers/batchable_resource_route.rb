module BatchActionResourceRoute
  def resources(*args, &block)
    super(*args) do
      yield if block_given?
        collection do
          get  :batch
          post :batch, action: :batch_edit_and_new
          put  :batch_update_and_create
        end
    end
  end
end

ActionDispatch::Routing::Mapper.send(:include, BatchActionResourceRoute)