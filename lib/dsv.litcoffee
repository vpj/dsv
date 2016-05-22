#DSV Parser

Constants

    CR = '\r'.charCodeAt 0
    LF = '\n'.charCodeAt 0
    EOL = '\n'
    EOF = -1

    if @TextDecoder?
     TEXT_DECODER = new @TextDecoder 'utf8'
    else
     TEXT_DECODER = null

    if Buffer?
     BUFFER = Buffer
    else
     BUFFER = null



##Parse

###Parse String

    parseString = (options) ->
     SEPARATOR = options.separator.charCodeAt 0
     if options.quote?
      QUOTE = options.quote.charCodeAt 0
     else
      QUOTE =  '\"'.charCodeAt 0

     text = options.text
     N = text.length
     I = 0 # current character index
     eol = false

Get next token

     token = ->
      return EOF if I >= N
      if eol
       eol = false
       return EOL

      j = I

Handle quotes

      if (text.charCodeAt j) is QUOTE
       i = j
       while i++ < N
        if (text.charCodeAt i) is QUOTE
         break if (text.charCodeAt i + 1) isnt QUOTE
         ++i
       I = i + 2
       c = text.charCodeAt i + 1

       if c is CR
        eol = true
        ++I if (text.charCodeAt i + 2) is LF
       else if c is LF
        eol = true
       else if i + 1 < N and c isnt SEPARATOR
        throw new Error "#{text.slice j, i + 10} DSV Quote error"

       return text.slice(j + 1, i).replace(/""/g, "\"")

If not quote

      while I < N
       c = text.charCodeAt I++
       k = 1
       if c is LF
        eol = true
       else if c is CR
        eol = true
        if (text.charCodeAt I) is LF
         ++I
         ++k
       else if c isnt SEPARATOR
        continue
       return text.slice(j, I - k)

Special case: last token before EOF

      return text.slice(j)


     rows = 0
     columns = []

Get tokens

     while (t = token()) isnt EOF
      n = 0
      t2 = token()

Skip empty rows

      continue if t is '' and (t2 is EOL or t2 is EOF)

Scan a line

      while t isnt EOL and t isnt EOF
       if columns.length is n
        columns.push new Array rows
       columns[n].push t
       n++
       if t2?
        t = t2
        t2 = null
       else
        t = token()

Fill other columns if empty

      while n < columns.length
       columns[n].push undefined
       n++

      rows++

Return columns

     return columns



###Parse Buffer

    parseBuffer = (options) ->
     SEPARATOR = options.separator.charCodeAt 0
     if options.quote?
      QUOTE = options.quote.charCodeAt 0
     else
      QUOTE =  '\"'.charCodeAt 0

     buffer = options.buffer
     N = options.length
     I = 0 # current character index
     eol = false

     if BUFFER?
      _slice = (buf, from, to) ->
       return new Buffer 0 if from >= to
       buf.slice from, to
     else
      _slice = (buf, from, to) ->
       return new Uint8Array 0 if from >= to
       new Uint8Array buf, from, to - from

     replaceQuote = (buf) ->
      i = 0
      j = 0
      while i < buf.length
       if buf[i] is QUOTE
        if i + 1 < buf.length and buf[i + 1] is QUOTE
         ++i
       buf[j] = buf[i]
       ++i
       ++j

      _slice buf, 0, j



Get next token

     token = ->
      return EOF if I >= N
      if eol
       eol = false
       return EOL

      j = I

Handle quotes

      if buffer[j] is QUOTE
       i = j
       while i++ < N
        if buffer[i] is QUOTE
         break if buffer[i + 1] isnt QUOTE
         ++i
       I = i + 2
       c = buffer[i + 1]

       if c is CR
        eol = true
        ++I if buffer[i + 2] is LF
       else if c is LF
        eol = true
       else if i + 1 < N and c isnt SEPARATOR
        throw new Error "#{_slice buffer, j, i + 10} DSV Quote error"

       return replaceQuote _slice buffer, j + 1, i

If not quote

      while I < N
       c = buffer[I++]
       k = 1
       if c is LF
        eol = true
       else if c is CR
        eol = true
        if buffer[I] is LF
         ++I
         ++k
       else if c isnt SEPARATOR
        continue
       return _slice buffer, j, I - k

Special case: last token before EOF

      return _slice buffer, j, N


     rows = 0
     columns = []

Get tokens

     while (t = token()) isnt EOF
      n = 0
      t2 = token()

Skip empty rows

      continue if t is '' and (t2 is EOL or t2 is EOF)

Scan a line

      while t isnt EOL and t isnt EOF
       if columns.length is n
        columns.push new Array rows
       columns[n].push t
       n++
       if t2?
        t = t2
        t2 = null
       else
        t = token()

Fill other columns if empty

      while n < columns.length
       columns[n].push undefined
       n++

      rows++

Return columns

     return columns



###Parse

    parse = (options) ->
     if options.text?
      parseString options
     else
      parseBuffer options


#Exports

    if module?
     module.exports = parse

    if window? or self?
     @dsv = parse
