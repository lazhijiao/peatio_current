class WithdrawChannel extends ExchangeModel.Model
  @configure 'WithdrawChannel', 'key', 'currency', 'resource_name'

  @initData: (records) ->
    ExchangeModel.Ajax.disable ->
      $.each records, (idx, record) ->
        WithdrawChannel.create(record)

  account: ->
    Account.findBy('currency', @currency)

window.WithdrawChannel = WithdrawChannel
