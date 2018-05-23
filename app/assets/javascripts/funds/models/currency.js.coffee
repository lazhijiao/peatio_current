class Currency extends ExchangeModel.Model
  @configure 'Currency', 'key', 'code', 'coin', 'blockchain'

  @initData: (records) ->
    ExchangeModel.Ajax.disable ->
      $.each records, (idx, record) ->
        currency = Currency.create(record.attributes)

window.Currency = Currency
