module Private
  module Withdraws
    class LitecoinsController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end
