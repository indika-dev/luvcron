local logger = require "luvcron.log"
local lulpeg = require "luvcron.lulpeg"
local re = lulpeg.re
local inspect = require "luvcron.inspect"
logger.usecolor = false

-- @module everything you need for compiling a cron expression to an AST representing the expression
local M = {}

-- @field whether logging is enabled or not
M.useLogger = false

-- @field the compile cronGrammarDef
M.cronGrammar = nil

-- @field the grammar definition
M.cronGrammarDef = [=[
cronExpression        <- {| ( special / minute_exp %s hour_exp %s day_of_month_exp %s month_exp %s day_of_week_exp %s year_exp %s command_exp) |} !.
minute_exp            <- {| {:directive: '' -> 'minute':} (all / list) |}
hour_exp              <- {| {:directive: '' -> 'hour':} (all / list) |}
day_of_month_exp      <- {| {:directive: '' -> 'dom':} (all / any / last / last_weekday_dom / last_dom / last_dom_range / list) |}
month_exp             <- {| {:directive: '' -> 'month':} (all / monthlist) |}
day_of_week_exp       <- {| {:directive: '' -> 'dow':} (all / any / last_dow_range / last_dow / nth_dow / daylist) |}
command_exp           <- {| {:directive: '' -> 'command':} {%a+} |}
year_exp              <- {| {:directive: '' -> 'year':} (all / list) |}

last_weekday_dom      <- ( { 'LW' }) -> {}
last_dom_range        <- ( { last } { '-' } { dom } ) -> {}
last_dom              <- ( { dom } { last } ) -> {}
dom                   <- %d+

last_dow_range        <- ({ last } { '-' } { dow } ) -> {}
last_dow              <- ( { dow } { last }) -> {}
nth_dow               <- ( { dow } { pound_sign } { nth_weekday_in_month } ) -> {}
nth_weekday_in_month  <- [1-5]

list                  <- ( singleint_or_range ( ',' singleint_or_range ) * )
singleint_or_range    <- range / increment / singleint
singleint             <- { int } -> {}
range                 <- ( { int } {'-'} { int } ) -> {}
increment             <- ( { int } {'/'} { int } ) -> {}
int                   <- %d+

daylist               <- ( singleday_or_range ( ',' singleday_or_range ) * )
singleday_or_range    <- dayrange / dayincrement / singleday
singleday             <- { day } -> {}
dayrange              <- ( { day } {'-'} { day } ) -> {}
dayincrement          <- ( { day } {'/'} { int } ) -> {}
day                   <- monday / tuesday / wednesday / thursday / friday / saturday / sunday
monday                <- '01' / '1' / 'mon' / 'monday'
tuesday               <- '02' / '2' / 'tue' / 'tuesday'
wednesday             <- '03' / '3' / 'wed' / 'wednesday'
thursday              <- '04' / '4' / 'thu' / 'thursday'
friday                <- '05' / '5' / 'fri' / 'friday'
saturday              <- '06' / '6' / 'sat' / 'saturday'
sunday                <- '07' / '7' / 'sun' / 'sunday'


monthlist             <- ( singlemonth_or_range ( ',' singlemonth_or_range ) * )
singlemonth_or_range  <- monthrange / monthincrement / singlemonth
singlemonth           <- { month } -> {}
monthrange            <- ( { month } {'-'} { month } ) -> {}
monthincrement        <- ( { month } {'/'} { int } ) -> {}
month                 <- january / february / march / april / may / june / july / august / september / october / november / december
january               <- '01' / '1' / 'jan' / 'january'
february              <- '02' / '2' / 'feb' / 'february'
march                 <- '03' / '3' / 'mar' / 'march'
april                 <- '04' / '4' / 'apr' / 'april'
may                   <- '05' / '5' / 'may' / 'may'
june                  <- '06' / '6' / 'jun' / 'june'
july                  <- '07' / '7' / 'jul' / 'july'
august                <- '08' / '8' / 'aug' / 'august'
september             <- '09' / '9' / 'sep' / 'september'
october               <- '10' / 'oct' / 'october'
november              <- '11' / 'nov' / 'november'
december              <- '12' / 'dec' / 'december'

last                  <- 'L'
all                   <- ( { '*' } ) -> {}
any                   <- ( { '?' } ) -> {}
pound_sign            <- '#'
special               <- {| {:special: '' -> '':} {reboot} / {yearly} / {annualy} / {monthly} / {weekly} / {daily} / {midnight} / {hourly} |}
reboot                <- '@reboot'
yearly                <- '@yearly'
annualy               <- '@annualy'
monthly               <- '@monthly'
weekly                <- '@weekly'
daily                 <- '@daily'
midnight              <- '@midnight'
hourly                <- '@hourly'
]=]

-- Shows the position in a string.
-- @tparam string s the string to show the position
-- @tparam int pos the position inside the string
-- @treturn {string}
M.showPosInString = function(s, pos)
  if pos >= string.len(s) then
    return s .. "[]"
  elseif pos <= 0 then
    return "[]" .. s
  end
  return s:sub(0, pos - 1) .. "[" .. s:sub(pos, pos) .. "]" .. s:sub(pos + 1, string.len(s))
end

-- parse a cron expression and return its AST
-- @tparam string expression the expression to parse
-- @treturn {table} contains the AST
-- @error returns an error, if compilation or AST generation fails
M.parseCronExpression = function(expression)
  if M.cronGrammar == nil then
    if M.useLogger then
      logger.trace "compiling Cron grammar"
    end
    local _, p = pcall(function()
      return re.compile(M.cronGrammarDef)
    end)
    if not p or type(p) ~= "userdata" then
      error("an error occured during compilation: " .. p)
    end
    M.cronGrammar = p
  end
  local error, ast = pcall(function()
    return M.cronGrammar:match(expression)
  end)
  if error and ast == nil then
    error('the expression "' .. expression .. '" is not parsable')
  elseif type(ast) == "number" then
    error('no AST was generated for the expression "' .. M.showPosInString(expression, ast) .. '"')
  elseif type(ast) == "string" then
    error('the following error occured during parsing "' .. expression .. '": ' .. ast)
  else
    if M.useLogger then
      logger.trace(self, 'AST("' .. expression .. '") -> \n' .. inspect(ast))
    end
  end
  return nil, ast
end

return M
