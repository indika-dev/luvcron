<<<<<<< HEAD
--
-- @see https://github.com/pygy/LuLPeg
--
local lulpeg = require("lulpeg")
local re = lulpeg.re
--
-- @see https://github.com/gorhill/cronexpr/blob/master/cronexpr_parse.go
--

local CronParser = {}

--
-- Caseof method table
-- @see http://lua-users.org/wiki/SwitchStatement
--
local switch = function(c)
  local swtbl = {
    casevar = c,
    caseof = function (self, code)
      local f
      if (self.casevar) then
        f = code[self.casevar] or code.default
      else
        f = code.missing or code.default
      end
      if f then
        if type(f)=="function" then
          return f(self.casevar,self)
        else
          error("case "..tostring(self.casevar).." not a function")
        end
      end
    end
  }
  return swtbl
end

local genericDefaultList = {
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  47,
  48,
  49,
  50,
  51,
  52,
  53,
  54,
  55,
  56,
  57,
  58,
  59,
}

local yearDefaultList = {
  1970,
  1971,
  1972,
  1973,
  1974,
  1975,
  1976,
  1977,
  1978,
  1979,
  1980,
  1981,
  1982,
  1983,
  1984,
  1985,
  1986,
  1987,
  1988,
  1989,
  1990,
  1991,
  1992,
  1993,
  1994,
  1995,
  1996,
  1997,
  1998,
  1999,
  2000,
  2001,
  2002,
  2003,
  2004,
  2005,
  2006,
  2007,
  2008,
  2009,
  2010,
  2011,
  2012,
  2013,
  2014,
  2015,
  2016,
  2017,
  2018,
  2019,
  2020,
  2021,
  2022,
  2023,
  2024,
  2025,
  2026,
  2027,
  2028,
  2029,
  2030,
  2031,
  2032,
  2033,
  2034,
  2035,
  2036,
  2037,
  2038,
  2039,
  2040,
  2041,
  2042,
  2043,
  2044,
  2045,
  2046,
  2047,
  2048,
  2049,
  2050,
  2051,
  2052,
  2053,
  2054,
  2055,
  2056,
  2057,
  2058,
  2059,
  2060,
  2061,
  2062,
  2063,
  2064,
  2065,
  2066,
  2067,
  2068,
  2069,
  2070,
  2071,
  2072,
  2073,
  2074,
  2075,
  2076,
  2077,
  2078,
  2079,
  2080,
  2081,
  2082,
  2083,
  2084,
  2085,
  2086,
  2087,
  2088,
  2089,
  2090,
  2091,
  2092,
  2093,
  2094,
  2095,
  2096,
  2097,
  2098,
  2099,
}

local numberTokens = {
  ["0"] = 0,
  ["1"] = 1,
  ["2"] = 2,
  ["3"] = 3,
  ["4"] = 4,
  ["5"] = 5,
  ["6"] = 6,
  ["7"] = 7,
  ["8"] = 8,
  ["9"] = 9,
  ["00"] = 0,
  ["01"] = 1,
  ["02"] = 2,
  ["03"] = 3,
  ["04"] = 4,
  ["05"] = 5,
  ["06"] = 6,
  ["07"] = 7,
  ["08"] = 8,
  ["09"] = 9,
  ["10"] = 10,
  ["11"] = 11,
  ["12"] = 12,
  ["13"] = 13,
  ["14"] = 14,
  ["15"] = 15,
  ["16"] = 16,
  ["17"] = 17,
  ["18"] = 18,
  ["19"] = 19,
  ["20"] = 20,
  ["21"] = 21,
  ["22"] = 22,
  ["23"] = 23,
  ["24"] = 24,
  ["25"] = 25,
  ["26"] = 26,
  ["27"] = 27,
  ["28"] = 28,
  ["29"] = 29,
  ["30"] = 30,
  ["31"] = 31,
  ["32"] = 32,
  ["33"] = 33,
  ["34"] = 34,
  ["35"] = 35,
  ["36"] = 36,
  ["37"] = 37,
  ["38"] = 38,
  ["39"] = 39,
  ["40"] = 40,
  ["41"] = 41,
  ["42"] = 42,
  ["43"] = 43,
  ["44"] = 44,
  ["45"] = 45,
  ["46"] = 46,
  ["47"] = 47,
  ["48"] = 48,
  ["49"] = 49,
  ["50"] = 50,
  ["51"] = 51,
  ["52"] = 52,
  ["53"] = 53,
  ["54"] = 54,
  ["55"] = 55,
  ["56"] = 56,
  ["57"] = 57,
  ["58"] = 58,
  ["59"] = 59,
  ["1970"] = 1970,
  ["1971"] = 1971,
  ["1972"] = 1972,
  ["1973"] = 1973,
  ["1974"] = 1974,
  ["1975"] = 1975,
  ["1976"] = 1976,
  ["1977"] = 1977,
  ["1978"] = 1978,
  ["1979"] = 1979,
  ["1980"] = 1980,
  ["1981"] = 1981,
  ["1982"] = 1982,
  ["1983"] = 1983,
  ["1984"] = 1984,
  ["1985"] = 1985,
  ["1986"] = 1986,
  ["1987"] = 1987,
  ["1988"] = 1988,
  ["1989"] = 1989,
  ["1990"] = 1990,
  ["1991"] = 1991,
  ["1992"] = 1992,
  ["1993"] = 1993,
  ["1994"] = 1994,
  ["1995"] = 1995,
  ["1996"] = 1996,
  ["1997"] = 1997,
  ["1998"] = 1998,
  ["1999"] = 1999,
  ["2000"] = 2000,
  ["2001"] = 2001,
  ["2002"] = 2002,
  ["2003"] = 2003,
  ["2004"] = 2004,
  ["2005"] = 2005,
  ["2006"] = 2006,
  ["2007"] = 2007,
  ["2008"] = 2008,
  ["2009"] = 2009,
  ["2010"] = 2010,
  ["2011"] = 2011,
  ["2012"] = 2012,
  ["2013"] = 2013,
  ["2014"] = 2014,
  ["2015"] = 2015,
  ["2016"] = 2016,
  ["2017"] = 2017,
  ["2018"] = 2018,
  ["2019"] = 2019,
  ["2020"] = 2020,
  ["2021"] = 2021,
  ["2022"] = 2022,
  ["2023"] = 2023,
  ["2024"] = 2024,
  ["2025"] = 2025,
  ["2026"] = 2026,
  ["2027"] = 2027,
  ["2028"] = 2028,
  ["2029"] = 2029,
  ["2030"] = 2030,
  ["2031"] = 2031,
  ["2032"] = 2032,
  ["2033"] = 2033,
  ["2034"] = 2034,
  ["2035"] = 2035,
  ["2036"] = 2036,
  ["2037"] = 2037,
  ["2038"] = 2038,
  ["2039"] = 2039,
  ["2040"] = 2040,
  ["2041"] = 2041,
  ["2042"] = 2042,
  ["2043"] = 2043,
  ["2044"] = 2044,
  ["2045"] = 2045,
  ["2046"] = 2046,
  ["2047"] = 2047,
  ["2048"] = 2048,
  ["2049"] = 2049,
  ["2050"] = 2050,
  ["2051"] = 2051,
  ["2052"] = 2052,
  ["2053"] = 2053,
  ["2054"] = 2054,
  ["2055"] = 2055,
  ["2056"] = 2056,
  ["2057"] = 2057,
  ["2058"] = 2058,
  ["2059"] = 2059,
  ["2060"] = 2060,
  ["2061"] = 2061,
  ["2062"] = 2062,
  ["2063"] = 2063,
  ["2064"] = 2064,
  ["2065"] = 2065,
  ["2066"] = 2066,
  ["2067"] = 2067,
  ["2068"] = 2068,
  ["2069"] = 2069,
  ["2070"] = 2070,
  ["2071"] = 2071,
  ["2072"] = 2072,
  ["2073"] = 2073,
  ["2074"] = 2074,
  ["2075"] = 2075,
  ["2076"] = 2076,
  ["2077"] = 2077,
  ["2078"] = 2078,
  ["2079"] = 2079,
  ["2080"] = 2080,
  ["2081"] = 2081,
  ["2082"] = 2082,
  ["2083"] = 2083,
  ["2084"] = 2084,
  ["2085"] = 2085,
  ["2086"] = 2086,
  ["2087"] = 2087,
  ["2088"] = 2088,
  ["2089"] = 2089,
  ["2090"] = 2090,
  ["2091"] = 2091,
  ["2092"] = 2092,
  ["2093"] = 2093,
  ["2094"] = 2094,
  ["2095"] = 2095,
  ["2096"] = 2096,
  ["2097"] = 2097,
  ["2098"] = 2098,
  ["2099"] = 2099,
}

local monthTokens = {
  ["1"] = 1,
  ["jan"] = 1,
  ["january"] = 1,
  ["2"] = 2,
  ["feb"] = 2,
  ["february"] = 2,
  ["3"] = 3,
  ["mar"] = 3,
  ["march"] = 3,
  ["4"] = 4,
  ["apr"] = 4,
  ["april"] = 4,
  ["5"] = 5,
  ["may"] = 5,
  ["6"] = 6,
  ["jun"] = 6,
  ["june"] = 6,
  ["7"] = 7,
  ["jul"] = 7,
  ["july"] = 7,
  ["8"] = 8,
  ["aug"] = 8,
  ["august"] = 8,
  ["9"] = 9,
  ["sep"] = 9,
  ["september"] = 9,
  ["10"] = 10,
  ["oct"] = 10,
  ["october"] = 10,
  ["11"] = 11,
  ["nov"] = 11,
  ["november"] = 11,
  ["12"] = 12,
  ["dec"] = 12,
  ["december"] = 12,
}

local dowTokens = {
  ["0"] = 0,
  ["sun"] = 0,
  ["sunday"] = 0,
  ["1"] = 1,
  ["mon"] = 1,
  ["monday"] = 1,
  ["2"] = 2,
  ["tue"] = 2,
  ["tuesday"] = 2,
  ["3"] = 3,
  ["wed"] = 3,
  ["wednesday"] = 3,
  ["4"] = 4,
  ["thu"] = 4,
  ["thursday"] = 4,
  ["5"] = 5,
  ["fri"] = 5,
  ["friday"] = 5,
  ["6"] = 6,
  ["sat"] = 6,
  ["saturday"] = 6,
  ["7"] = 0,
}

-- gsplit: iterate over substrings in a string separated by a pattern
--
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
--
-- Returns: iterator
--
-- Usage:
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
--
-- @see https://stackoverflow.com/a/43582076
local gsplit = function(text, pattern, plain)
  local splitStart, length = 1, #text
  return function()
    if splitStart then
      local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
      local ret
      if not sepStart then
        ret = string.sub(text, splitStart)
        splitStart = nil
      elseif sepEnd < sepStart then
        -- Empty separator!
        ret = string.sub(text, splitStart, sepStart)
        if sepStart < length then
          splitStart = sepStart + 1
        else
          splitStart = nil
        end
      else
        ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ""
        splitStart = sepEnd + 1
      end
      return ret
    end
  end
end

-- split: split a string into substrings separated by a pattern.
--
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
--
-- Returns: table (a sequence table containing the substrings)
--
-- @see https://stackoverflow.com/a/43582076
local split = function(text, pattern, plain)
  local ret = {}
  for match in gsplit(text, pattern, plain) do
    table.insert(ret, match)
  end
  return ret
end

--
-- create class FieldDescriptor
--
local FieldDescriptor = { mt = {} }
FieldDescriptor.prototype = {
  name = "",
  min = 0,
  max = 0,
  defaultList = {},
  valuePattern = "",
  atoi = function(s)
    return numberTokens[s]
  end,
}
FieldDescriptor.mt.__index = function(_, key)
  return FieldDescriptor.prototype[key]
end

function FieldDescriptor.new(name, min, max, defaultList, valuePattern)
  local result = { name = name, min = min, max = max, defaultList = defaultList, valuePattern = valuePattern }
  setmetatable(result, FieldDescriptor.mt)
  return result
end
--
-- class FieldDescriptor
--

--
-- create struct cronDirective
--

local none = 0 -- <const>
local one = 1 -- <const>
local span = 2 -- <const>
local all = 3 -- <const>

local CronDirective = { mt={}}
CronDirective.prototype = {
	kind = none,
	first = 0,
	last = 0,
	step = 0,
	sbeg = 0,
	send = 0
}

function CronDirective.new(kind, first, last, step, sbeg, send)
  local result = { kind = kind, first = first, last = last, step = step, sbeg = sbeg, send=send }
  setmetatable(result, CronDirective.mt)
  return result
end

function CronDirective.copy()
  local result = { kind = CronDirective.prototype.kind, first = CronDirective.prototype.first, last = CronDirective.prototype.last, step = CronDirective.prototype.step, sbeg = CronDirective.prototype.sbeg, send= CronDirective.prototype.send }
  setmetatable(result, CronDirective.mt)
  return result
end
--
-- cronDirective
--

local tableCopy = function(source, startIndex, endIndex)
  local result = {}
  for i = startIndex, endIndex do
    table.insert(result, source[i])
  end
  return result
end

local secondDescriptor = FieldDescriptor.new(
  "second",
  0,
  59,
  tableCopy(genericDefaultList, 0, 60),
  "0?[0-9]+"
)
local minuteDescriptor = FieldDescriptor.new(
  "minute",
  0,
  59,
  tableCopy(genericDefaultList, 0, 60),
  "0?[0-9]+"
)
local hourDescriptor = FieldDescriptor.new("hour", 0, 23, tableCopy(genericDefaultList, 0, 24), "0?[0-9]|1[0-9]|2[0-3]")
local domDescriptor = FieldDescriptor.new(
  "day-of-month",
  1,
  31,
  tableCopy(genericDefaultList, 1, 32),
  "0?[1-9]|[12][0-9]|3[01]"
)
local monthDescriptor = FieldDescriptor.new(
  "month",
  1,
  12,
  tableCopy(genericDefaultList, 1, 13),
  "0?[1-9]|1[012]|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec|january|february|march|april|march|april|june|july|august|september|october|november|december"
)
monthDescriptor.atoi = function(s)
  return monthTokens[s]
end

local dowDescriptor = FieldDescriptor.new(
  "day-of-week",
  0,
  6,
  tableCopy(genericDefaultList, 0, 7),
  "0?[0-7]|sun|mon|tue|wed|thu|fri|sat|sunday|monday|tuesday|wednesday|thursday|friday|saturday"
)
dowDescriptor.atoi = function(s)
  return dowTokens[s]
end

local yearDescriptor = FieldDescriptor.new(
  "year",
  1970,
  2099,
  tableCopy(yearDefaultList, 0, #yearDefaultList),
  "19[789][0-9]|20[0-9]{2}"
)

local cronNormalizer = {
  ["@yearly"] = "0 0 0 1 1 * *",
  ["@annually"] = "0 0 0 1 1 * *",
  ["@monthly"] = "0 0 0 1 * * *",
  ["@weekly"] = "0 0 0 * * 0 *",
  ["@daily"] = "0 0 0 * * * *",
  ["@hourly"] = "0 0 * * * * *",
}

local populateOne=function(values, position)
	values[position] = true
end

local populateMany=function(values, min, max, step)
	for i = min,max,step do
		values[i] = true
  end
end

local toList=function(set)
	local result = {}
  for k, _ in ipairs(set) do
    table.insert(result, k)
  end
  table.sort(result, function(x,y) return x<y end)
	return result
end

local layoutWildcard        = "([\\*\\?])"
	local layoutValue               = "^(%value%)$"
	local layoutRange               = "(%value%)-(%value%)"
	local layoutWildcardAndInterval = "^\\*/(\\d+)$"
	local layoutValueAndInterval    = "^(%value%)/(\\d+)$"
	local layoutRangeAndInterval    = "^(%value%)-(%value%)/(\\d+)$"
	local layoutLastDom             = "^l$"
	local layoutWorkdom             = "^(%value%)w$"
	local layoutLastWorkdom         = "^lw$"
	local layoutDowOfLastWeek       = "^(%value%)l$"
	local layoutDowOfSpecificWeek   = "^(%value%)#([1-5])$"
	local fieldFinder               = regexp.MustCompile("\\S+")
	local entryFinder               = "[^,]+"
	local layoutRegexp              = {} -- make(map[string]*regexp.Regexp)
	local layoutRegexpLock          = sync.Mutex


---comment
---@tparam string s the cron expression to parse
---@tparam FieldDescriptor desc the FieldDescriptor to parse with
---@treturn {{CronDirective, ...}, error} parsed directives for the given string s
local genericFieldParse = function(s, desc)
	-- At least one entry must be present
	local indices = split(s, entryFinder, false)
	if #indices == 0 then
		return nil, error(desc.name .. "field: missing directive")
  end

	local directives = {} -- make([]*cronDirective, 0, len(indices))

  for index, value in ipairs(indices) do
    local directive = CronDirective.copy()
	-- for i := range indices {
	-- 	directive := cronDirective{
	-- 		sbeg: indices[i][0],
	-- 		send: indices[i][1],
	-- 	}
		local snormal = string.lower(value)
		-- "*"
		if string.gmatch(snormal, string.gsub(layoutWildcard, "%value%", desc.valuePattern)) then
			directive.kind = all
			directive.first = desc.min
			directive.last = desc.max
			directive.step = 1
		  table.insert(directives, directive)
      -- goto skip_to_next
    end
		-- "5"
		if string.gmatch(snormal, string.gsub(layoutValue,"%value%",desc.valuePattern)) then
			directive.kind = one
			directive.first = desc.atoi(snormal)
      table.insert(directives, directive)
      -- goto skip_to_next
	  end
		-- "5-20"
		pairs := makeLayoutRegexp(layoutRange, desc.valuePattern).FindStringSubmatchIndex(snormal)
		if len(pairs) > 0 {
			directive.kind = span
			directive.first = desc.atoi(snormal[pairs[2]:pairs[3]])
			directive.last = desc.atoi(snormal[pairs[4]:pairs[5]])
			directive.step = 1
			directives = append(directives, &directive)
			continue
		}
		// `*/2`
		pairs = makeLayoutRegexp(layoutWildcardAndInterval, desc.valuePattern).FindStringSubmatchIndex(snormal)
		if len(pairs) > 0 {
			directive.kind = span
			directive.first = desc.min
			directive.last = desc.max
			directive.step = atoi(snormal[pairs[2]:pairs[3]])
			if directive.step < 1 || directive.step > desc.max {
				return nil, fmt.Errorf("invalid interval %s", snormal)
			}
			directives = append(directives, &directive)
			continue
		}
		// `5/2`
		pairs = makeLayoutRegexp(layoutValueAndInterval, desc.valuePattern).FindStringSubmatchIndex(snormal)
		if len(pairs) > 0 {
			directive.kind = span
			directive.first = desc.atoi(snormal[pairs[2]:pairs[3]])
			directive.last = desc.max
			directive.step = atoi(snormal[pairs[4]:pairs[5]])
			if directive.step < 1 || directive.step > desc.max {
				return nil, fmt.Errorf("invalid interval %s", snormal)
			}
			directives = append(directives, &directive)
			continue
		}
		// `5-20/2`
		pairs = makeLayoutRegexp(layoutRangeAndInterval, desc.valuePattern).FindStringSubmatchIndex(snormal)
		if len(pairs) > 0 {
			directive.kind = span
			directive.first = desc.atoi(snormal[pairs[2]:pairs[3]])
			directive.last = desc.atoi(snormal[pairs[4]:pairs[5]])
			directive.step = atoi(snormal[pairs[6]:pairs[7]])
			if directive.step < 1 || directive.step > desc.max {
				return nil, fmt.Errorf("invalid interval %s", snormal)
			}
			directives = append(directives, &directive)
			continue
		}
		// No behavior for this one, let caller deal with it
		directive.kind = none
		directives = append(directives, &directive)
	}
	return directives, nil
end

local genericFieldHandler = function(s, fieldDescriptor)
	local directives, err = genericFieldParse(s, fieldDescriptor)
	if err ~= nil then
		return nil, err
end
  switch(directive.kind) : caseof {
  none: function(x) return nil, 
}
	values := make(map[int]bool)
	for _, directive := range directives {
		switch directive.kind {
		case none:
			return nil, fmt.Errorf("syntax error in %s field: '%s'", desc.name, s[directive.sbeg:directive.send])
		case one:
			populateOne(values, directive.first)
		case span:
			populateMany(values, directive.first, directive.last, directive.step)
		case all:
			return desc.defaultList, nil
		}
	}
	return toList(values), nil
end

func (expr *Expression) secondFieldHandler(s string) error {
	var err error
	expr.secondList, err = genericFieldHandler(s, secondDescriptor)
	return err
}

CronParser.parse = function(expression)
  local list = split(expression, " ", true)
end

return CronParser
