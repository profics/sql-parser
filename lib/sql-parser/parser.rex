class SQLParser::Parser

option
  ignorecase

inner
  def mysub(string, pattern, replacement)
    result = string.gsub(pattern, replacement)
    puts "s: #{string}  p: #{pattern}  r: #{replacement}  = #{result}"
    result
  end

  def dequote(string, quote)
    s = string.gsub(quote+quote, quote)
    s = s.gsub("\\r", "\r")
    s = s.gsub("\\n", "\n")
    s = s.gsub(%r{\\(['"\\])}, '\1')
  end

macro
  DIGIT   [0-9]
  UINT    {DIGIT}+
  BLANK   \s+

  YEARS   {UINT}
  MONTHS  {UINT}
  DAYS    {UINT}
  DATE    {YEARS}-{MONTHS}-{DAYS}

  IDENT   \w+

  STRLITS ([^'\\]|''|\\[rn'"\\])
  STRLITD ([^"\\]|""|\\[rn'"\\])

rule
# [:state]  pattern       [actions]

# literals
            "{DATE}"      { [:date_string, Date.parse(text)] }
            '{DATE}'      { [:date_string, Date.parse(text)] }

            '             { @state = :STRS;  [:quote, text] }
  :STRS     {STRLITS}+    {                  [:character_string_literal, dequote(text, "'")] }
  :STRS     '             { @state = nil;    [:quote, text] }

            "             { @state = :STRD;  [:quote, text] }
  :STRD     {STRLITD}+    {                  [:character_string_literal, dequote(text, '"')] }
  :STRD     "             { @state = nil;    [:quote, text] }

            {UINT}        { [:unsigned_integer, text.to_i] }

# skip
            {BLANK}       # no action

# keywords
            SELECT        { [:SELECT, text] }
            DATE          { [:DATE, text] }
            ASC           { [:ASC, text] }
            AS            { [:AS, text] }
            FROM          { [:FROM, text] }
            WHERE         { [:WHERE, text] }
            BETWEEN       { [:BETWEEN, text] }
            AND           { [:AND, text] }
            NOT           { [:NOT, text] }
            INNER         { [:INNER, text] }
            INSERT        { [:INSERT, text] }
            INTO          { [:INTO, text] }
            IN            { [:IN, text] }
            ORDER         { [:ORDER, text] }
            OR            { [:OR, text] }
            LIKE          { [:LIKE, text] }
            IS            { [:IS, text] }
            NULL          { [:NULL, text] }
            COUNT         { [:COUNT, text] }
            AVG           { [:AVG, text] }
            MAX           { [:MAX, text] }
            MIN           { [:MIN, text] }
            SUM           { [:SUM, text] }
            GROUP         { [:GROUP, text] }
            BY            { [:BY, text] }
            HAVING        { [:HAVING, text] }
            CROSS         { [:CROSS, text] }
            JOIN          { [:JOIN, text] }
            ON            { [:ON, text] }
            LEFT          { [:LEFT, text] }
            OUTER         { [:OUTER, text] }
            RIGHT         { [:RIGHT, text] }
            FULL          { [:FULL, text] }
            USING         { [:USING, text] }
            EXISTS        { [:EXISTS, text] }
            DESC          { [:DESC, text] }
            CURRENT_USER  { [:CURRENT_USER, text] }
            VALUES        { [:VALUES, text] }

# tokens
            E             { [:E, text] }

            <>            { [:not_equals_operator, text] }
            !=            { [:not_equals_operator, text] }
            =             { [:equals_operator, text] }
            <=            { [:less_than_or_equals_operator, text] }
            <             { [:less_than_operator, text] }
            >=            { [:greater_than_or_equals_operator, text] }
            >             { [:greater_than_operator, text] }

            \(            { [:left_paren, text] }
            \)            { [:right_paren, text] }
            \*            { [:asterisk, text] }
            \/            { [:solidus, text] }
            \+            { [:plus_sign, text] }
            \-            { [:minus_sign, text] }
            \.            { [:period, text] }
            ,             { [:comma, text] }

# identifier
            `{IDENT}`     { [:identifier, text[1..-2]] }
            {IDENT}       { [:identifier, text] }

end
