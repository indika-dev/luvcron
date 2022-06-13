local M = {}

-- local p = [=[

-- pattern         <- exp !.
-- exp             <- S (grammar / alternative)

-- alternative     <- seq ('/' S seq)*
-- seq             <- prefix*
-- prefix          <- '&' S prefix / '!' S prefix / suffix
-- suffix          <- primary S (([+*?]
--                             / '^' [+-]? num
--                             / '->' S (string / '{}' / name)
--                             / '=>' S name) S)*

-- primary         <- '(' exp ')' / string / class / defined
--                  / '{:' (name ':')? exp ':}'
--                  / '=' name
--                  / '{}'
--                  / '{~' exp '~}'
--                  / '{' exp '}'
--                  / '.'
--                  / name S !arrow
--                  / '<' name '>'          -- old-style non terminals

-- grammar         <- definition+
-- definition      <- name S arrow exp

-- class           <- '[' '^'? item (!']' item)* ']'
-- item            <- defined / range / .
-- range           <- . '-' [^]]

-- S               <- (%s / '--' [^%nl]*)*   -- spaces and comments
-- name            <- [A-Za-z][A-Za-z0-9_]*
-- arrow           <- '<-'
-- num             <- [0-9]+
-- string          <- '"' [^"]* '"' / "'" [^']* "'"
-- defined         <- '%' name

-- ]=]

local cronExpression = [=[
cronExpression        <- (special / minute_exp %s hour_exp %s day_of_month_exp %s month_exp %s day_of_week_exp %s (year_exp %s)? command_exp) !.
minute_exp            <- all / list
hour_exp              <- all / list
day_of_month_exp      <- all / any / last / last_weekday_dom / last_dom / last_dom_range / list
month_exp             <- all / monthlist
day_of_week_exp       <- all / any / last_dow_range / last_dow / nth_dow / daylist
command_exp           <- %a+
year_exp              <- all / list

last_weekday_dom      <- 'LW'
last_dom_range        <- last '-' dom
last_dom              <- dom last
dom                   <- %d+

last_dow_range        <- last '-' dow
last_dow              <- dow last
nth_dow               <- dow pound_sign nth_weekday_in_month
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
all                   <- '*'
any                   <- '?'
pound_sign            <- '#'
special               <- reboot / yearly / annualy / monthly / weekly / daily / midnight / hourly
reboot                <- '@reboot'
yearly                <- '@yearly'
annualy               <- '@annualy'
monthly               <- '@monthly'
weekly                <- '@weekly'
daily                 <- '@daily'
midnight              <- '@midnight'
hourly                <- '@hourly'
]=]

local test_cronExpression = [=[
cronExpression        <- (special / minute_exp %s hour_exp) !.
minute_exp            <- {| {:field: '' -> 'minute':} (all / list) |}
hour_exp              <- {| {:field: '' -> 'hour':} (all / any) |}

number                <- {[0-9]+}

all                   <- {| {:op: '' -> 'all':} '*' |}
any                   <- {| {:op: '' -> 'any':} '?' |}
last_weekday_dom      <- 'LW'

list                  <- ( singleint_or_range ( ',' singleint_or_range ) * )
singleint_or_range    <- range / increment / singleint
singleint             <- { int } -> {}
range                 <- ( { int } {'-'} { int } ) -> {}
increment             <- ( { int } {'/'} { int } ) -> {}
int                   <- %d+

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

local sort, rep, concat = table.sort, string.rep, table.concat

-- shows the position in a string
-- @tparam string s the string to show the position
-- @tparam int pos the position inside the string
local function showPosInString(s, pos)
  if pos >= string.len(s) then
    return s .. "[]"
  elseif pos <= 0 then
    return "[]" .. s
  end
  return s:sub(0, pos - 1) .. "[" .. s:sub(pos, pos) .. "]" .. s:sub(pos + 1, string.len(s))
end

local function serialise(var, sorted, indent)
  if type(var) == "string" then
    return "'" .. var .. "'"
  elseif type(var) == "table" then
    local keys = {}
    for key, _ in pairs(var) do
      keys[#keys + 1] = key
    end
    if sorted then
      sort(keys, function(a, b)
        if type(a) == type(b) and (type(a) == "number" or type(a) == "string") then
          return a < b
        elseif type(a) == "number" and type(b) ~= "number" then
          return true
        else
          return false
        end
      end)
    end
    local strings = {}
    local indent = indent or 0
    for _, key in ipairs(keys) do
      strings[#strings + 1] = rep("\t", indent + 1)
        .. serialise(key, sorted, indent + 1)
        .. " = "
        .. serialise(var[key], sorted, indent + 1)
    end
    return "table (\n" .. concat(strings, "\n") .. "\n" .. rep("\t", indent) .. ")"
  else
    return tostring(var)
  end
end

local logger = require "lua.luvcron.log"
local lulpeg = require "lua.luvcron.lulpeg"
local re = lulpeg.re
local inspect = require "lua.luvcron.inspect"
logger.usecolor = false

logger.info(self, "compiling cronExpression")
local p = re.compile(cronExpression)
if not p or type(p) ~= "userdata" then
  logger.error(self, "an error occured during compilation: " .. p)
else
  local testExpression = "* * * * ? * execute"
  -- local testExpression = "10,10-5,10/5 ?"
  -- local testExpression = "@reboot"

  local ast = p:match(testExpression)
  if not ast or type(ast) ~= "table" then
    logger.error(self, "an error occured while parsing @ pos " .. ast .. " : " .. showPosInString(testExpression, ast))
  else
    print(inspect(ast))
  end
end

-- local p = re.compile [[
--       text <- {~ item* ~}
--       item <- macro / [^()] / '(' item* ')'
--       arg <- ' '* {~ (!',' item)* ~}
--       args <- '(' arg (',' arg)* ')'
--       -- now we define some macros
--       macro <- ('apply' args) -> '%1(%2)'
--              / ('add' args) -> '%1 + %2'
--              / ('mul' args) -> '%1 * %2'
-- ]]

-- print(p:match "add(mul(a,b), apply(f,x))")

M.main = function() end

return M
