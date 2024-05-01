" Define syntax group time [1:45 PM]
syntax match time /\[\d\{1,2}:\d\{2}\s\w\{2}\]/
" Set highlighting attributes for time
highlight link time PreProc
" Define syntax group user names <username>
syntax match userNames /^<[a-zA-Z0-9]*>/
" Set highlighting attributes for user names
highlight link userNames Identifier
