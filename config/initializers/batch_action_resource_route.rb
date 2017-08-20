module BatchActionResourceRoute
  def resources(*args, &block)
    super(*args) do
      yield if block_given?
      member do
        get  :batch_new
        post :batch, action: :batch_create_and_update
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send(:include, BatchActionResourceRoute)