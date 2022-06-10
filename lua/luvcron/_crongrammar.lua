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
cronExpression        <- special / exp !.
exp                   <- minute_exp hour_exp day_of_month_exp month_exp day_of_week_exp year_exp command_exp
minute_exp            <- all / minute_increment / minute (',' minute / minute_range)*
hour_exp              <- all / hour_increment / hour (',' hour / hour_range)*
day_of_month_exp      <- all / any / last / last_weekday_dom / last_dom / last_dom_range / dom_increment / dom (',' dom / dom_range)*
month_exp             <- all / month_increment / month (',' month / month_range)*
day_of_week_exp       <- all / any / last_dow_range / last_dow / nth_dow / dow (',' dow / dow_range)*
command_exp           <- (year_exp ' ')? ([A-Za-z][A-Za-z0-9_/])*
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

month_increment       <- month '/' ([0]?[1-9] / [1][012])
month_range           <- month '-' month
month                 <- [0]?[1-9] / [1][012]
                        / 'jan' / 'feb' / 'mar' / 'apr' / 'may' / 'jun'
                        / 'jul' / 'aug' / 'sep' / 'oct' / 'nov' / 'dec'
                        / 'january' / 'february' / 'march' / 'april' / 'march'
                        / 'april' / 'june' / 'july' / 'august' / 'september'
                        / 'october' / 'november' / 'december'

last_dow_range        <- last '-' dow
last_dow              <- dow last
nth_dow               <- dow pound_sign nth_weekday_in_month
dow                   <- [0]?[0-7]
                        / 'sun' / 'mon' / 'tue' / 'wed' / 'thu' / 'fri' / 'sat'
                        / 'sunday' / 'monday' / 'tuesday' / 'wednesday' / 'thursday' / 'friday' / 'saturday'
nth_weekday_in_month  <- [1-5]

year_increment        <- year '/' ([0]?[1-9]*)
year_range            <- year '-' year
year                  <- [1][9][789][0-9] / [2][0][0-9]*

last                  <- 'L'
all                   <- '*'
any                   <- '?'
pound_sign            <- '#'
special               <- '@reboot' / '@yearly' / '@annualy' / '@monthly' / '@weekly' / '@daily' / '@midnight' / '@hourly'
]=]

M.main = function()
  local lulpeg = require "user.lulpeg"
  local re = lulpeg.re
  -- print(re.match(p, p))
  print(re.match("* * * * ? *", cronExpression))
end

return M
