#DSV Parser

    QUOTE = '\"'.charCodeAt 0
    CR = '\r'.charCodeAt 0
    LF = '\n'.charCodeAt 0



##Parse

    parse = (options) ->
     SEPARATOR = options.separator.charCodeAt 0
     text = options.text
     EOL = '\n' # sentinel value for end-of-line
     EOF = -1 # sentinel value for end-of-file
     columns = []
     N = text.length
     I = 0 # current character index
     eol = false
     rows = 0

     token = ->
      return EOF if I >= N
      if eol
       eol = false
       return EOL

      # special case: quotes
      j = I
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
       return text.slice(j + 1, i).replace(/""/g, "\"")

      #common case: find next delimiter or newline
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

      #special case: last token before EOF
      return text.slice(j)

     while (t = token())isnt EOF
      n = 0
      while t isnt EOL and t isnt EOF
       if columns.length is n
        columns.push new Array rows
       columns[n].push t
       n++
       t = token()
      while n < columns.length
       columns[n].push undefined
       n++
      rows++


     return columns


#Exports

    if module?
     module.exports = parse

    if window? or self?
     @dsv = parse
