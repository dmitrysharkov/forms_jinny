Chekers =
  greater_than: (number, option) -> number > option
  greater_than_or_equal_to: (number, option) -> number >= option
  equal_to: (number, option) -> number is option
  less_than: (number, option) -> number < option
  less_than_or_equal_to: (number, option) -> number <= option
  other_than: (number, option) -> number isnt option

EvenChekers =
  even: (number) -> number % 2 is 0
  odd: (number) -> number % 2 isnt 0

refineOptionValue = (record, value) ->
  number = Number(value)
  return number unless isNaN(number)

  value = record.evaluate(value)
  number = Number(value)
  return number unless isNaN(number)

  throw "Can't resolve numericality validator value #{ value }"

@FormsJinny.config.validators.numericality = (record, attribute, value) ->
  number = Number(value)
  return 'not_a_number' if isNaN(number)

  if @options.only_integer
    return 'not_an_integer' unless number % 1 is 0

  errors = []

  for opt, func of EvenChekers when @options[opt]?
    errors.push opt unless func(number)

  for opt, func of Chekers when @options[opt]?
    optValue = refineOptionValue(record, @options[opt])
    errors.push FormsJinny.newError(opt, optValue) unless func(number, optValue)

  errors

