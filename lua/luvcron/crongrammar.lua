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
cronExpression        <- {| special / exp |}
exp                   <- {| minute_exp s hour_exp s day_of_month_exp s month_exp s day_of_week_exp s command_exp |}
minute_exp            <- all / minute_increment / minute (',' minute / minute_range)*
hour_exp              <- all / hour_increment / hour (',' hour / hour_range)*
day_of_month_exp      <- all / any / last / last_weekday_dom / last_dom / last_dom_range / dom_increment / dom (',' dom / dom_range)*
month_exp             <- all / month_increment / month (',' month / month_range)*
day_of_week_exp       <- all / any / last_dow_range / last_dow / nth_dow / dow (',' dow / dow_range)*
command_exp           <- (year_exp s)? cmd_exp
year_exp              <- all / year_increment / year (',' year / year_range)*

minute_range          <- minute '-' minute
minute_increment      <- minute '/' minute
minute                <- [0]?[0-9] / [1-5][0-9]

hour_range            <- hour '-' hour
hour_increment        <- hour '/' hour
hour                  <- [0]?[0-9] / [1][0-9] / [2][0-3]

dom_increment         <- dom '/' dom
dom_range             <- dom '-' dom
last_weekday_dom      <- 'LW'
last_dom_range        <- last '-' dom
last_dom              <- dom last
dom                   <- [0]?[1-9] / [12][0-9] / [3][01]

month_increment       <- month '/' moincrement
month_range           <- month '-' month
month                 <- january / february / march / april / may / june / july / august / september / october / november / december
moincrement           <- [0]?[1-9] / [1][012]

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

last_dow_range        <- last '-' dow
last_dow              <- dow last
nth_dow               <- dow pound_sign nth_weekday_in_month
dow                   <- monday / tuesday / wednesday / thursday / friday / saturday / sunday
monday                <- '01' / '1' / 'mon' / 'monday'
tuesday               <- '02' / '2' / 'tue' / 'tuesday'
wednesday             <- '03' / '3' / 'wed' / 'wednesday'
thursday              <- '04' / '4' / 'thu' / 'thursday'
friday                <- '05' / '5' / 'fri' / 'friday'
saturday              <- '06' / '6' / 'sat' / 'saturday'
sunday                <- '07' / '7' / 'sun' / 'sunday'
nth_weekday_in_month  <- [1-5]

year_increment        <- year '/' yincrement
year_range            <- year '-' year
year                  <- [1970-2099]
yincrement            <- [0]?[1-9]*

cmd_exp               <- ([A-Za-z][A-Za-z0-9_/])*

last                  <- 'L'
all                   <- '*'
any                   <- '?'
pound_sign            <- '#'
special               <- {| reboot / yearly / annualy / monthly / weekly / daily / midnight / hourly |}
reboot                <- '@reboot'
yearly                <- '@yearly'
annualy               <- '@annualy'
monthly               <- '@monthly'
weekly                <- '@weekly'
daily                 <- '@daily'
midnight              <- '@midnight'
hourly                <- '@hourly'

--define space char
s                <- %s
]=]

local test_cronExpression = [=[
cronExpression        <- {| exp |}
exp                   <- {| all / any |}

last                  <- 'L'
all                   <- '*'
any                   <- '?'
pound_sign            <- '#'

--define space char
s                <- %s
]=]

local lulpeg = require "lua.luvcron.lulpeg"
local re = lulpeg.re
local p = re.compile(test_cronExpression)
print(p:match "*")
-- print(p:match "* * * * ? *")

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
