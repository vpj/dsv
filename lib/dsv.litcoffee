#DSV Parser

Constants

    CR = '\r'.charCodeAt 0
    LF = '\n'.charCodeAt 0
    EOL = '\n'
    EOF = -1



##Parse

##Parse String

    parseString = (options) ->
     SEPARATOR = options.separator.charCodeAt 0
     QUOTE = options.quote
     if not QUOTE?
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




#Exports

    if module?
     module.exports = parse

    if window? or self?
     @dsv = parse
