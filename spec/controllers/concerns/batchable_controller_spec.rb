require 'rails_helper'

RSpec.describe BatchableControllerConcern, type: :controller do

  controller(ApplicationController) do
    include Batchable

    def fake_action
      redirect_to '/an_url'
    end
  end

  before { routes.draw { get 'fake_action' => 'anonymous#fake_action' } }
end
