" Author: Gergely Kontra <kgergely@mcl.hu>
" Version: 0.2
" Description:
"    Adds a new menu to vim
"    You can add your favourite files (and directories) into it
"
" Installation: Drop it into your plugin directory
"
" History:
"    0.1: Initial release
"    0.2:
"	  * Fixed bug, which caused same files to hide each other
"         * Your favourite files must be located at $FAVOURITES
"	  * You can Edit the favourites. Menus will updated, when you save
"         * When you click on the menu, it invokes the fav_fun function
"         * You can choose cascade delete menu by defining fav_cascade_del
"	    (at startup!)
"         * You can add directories to your favourites
"           Thanks to the_intellectual_person <arun_kumar_ks@hotmail.com>,
"           who gave me a patch for this
"    0.21:* Fixed bug, which caused not to update you menu, when you remove
"	    one of your favourites
"	  * Fixed REGEXP bug (When removing files)
"    0.22:* Nice fallbacks, if $FAVOURITES is not defined.
"         * fav_fun is renamed to OPEN_FUNC, so you can store it in your
"           viminfo file, and can be reused in my MRU script. Sorry for the
"           inconvinience.
"
" TODO:
"    Are all valid filenames escaped? (Feedback please!)
"
let s:cascade_del=exists('fav_cascade_del')

if !exists('$FAVOURITES')
  if has('unix')
    let $FAVOURITES=$HOME.'/.vimfavourites'
  else
    let $FAVOURITES=$VIM.'\_vimfavourites'
  end
end

if !exists('SpWhenModified') "integration with FavMenu
  fu! SpWhenModified(f)
    if &mod
      exe 'sp '.a:f
    else
      exe 'e '.a:f
    endif
  endf
  fu! SpWhenNamedOrModified(f)
    if bufname('')!='' || &mod
      exe 'sp '.a:f
    else
      exe 'e '.a:f
    end
  endf
  fu! OpenFile()
    if exists('g:OPEN_FUNC')
      retu g:OPEN_FUNC
    el
      retu 'SpWhenModified'
    en
  endf
end
fu! <SID>AddThisFile(name)
  let fullname=fnamemodify(a:name,':p')
  let path=escape(fnamemodify(fullname,':p:h'),'\. #%')
  let fn=escape(fnamemodify(fullname,':p:t'),'\. #%')
  if strlen(fn)
    let item='[&'.s:cnt.']\ \ '.fn.'<Tab>'.path
  else
    let item='[&'.s:cnt.']\ \ <DIR><Tab>'.path
  endif
  let s:cnt=s:cnt+1
  exe 'amenu Fa&vourites.'.item." :call \<C-r>=OpenFile()<CR>('".escape(fullname,'#%')."')<CR>"
  if s:cascade_del
    exe 'amenu Fa&vourites.Remove.'.item." :call <SID>RemoveThisFile('".fullname."')<CR>"
  endif
endf

fu! <SID>AddThisFilePermanent(name)
  let fullname=fnamemodify(a:name,':p')
  call <SID>AddThisFile(a:name)
  sp $FAVOURITES|set nobl|1
  if search('^\V'.escape(fullname,'\').'\$','w')
    call confirm('This is already in your favourites file!',' :-/ ',1,'W')
  else
    exe 'norm Go'.fullname."\<Esc>"
  endif
  let pm=&pm|let &pm=''|wq|let &pm=pm
endf

fu! <SID>RemoveThisFile(name)
  let fullname=fnamemodify(a:name,':p')
  sp $FAVOURITES|set nobl
  if search('^\V'.escape(fullname,'\').'\$','w')
    d _
  else
    call confirm('Cannot find this file in your favourites file!',' :-/ ',1,'e')
  endif
  let pm=&pm|let &pm=''|wq|let &pm=pm
  call <SID>Init()
endf

fu! <SID>Init()
  let s:cnt=1
  silent! aunmenu Fa&vourites
  amenu 65.1 Fa&vourites.&Add\ current\ file :call <SID>AddThisFilePermanent(@%)<CR>
  amenu 65.4 Fa&vourites.&Edit\ favourites :call <C-r>=OpenFile()<CR>($FAVOURITES)<CR>:au BufWritePost <C-r>% call <SID>Init()<CR>
  amenu 65.5 Fa&vourites.-sep-	<nul>
  if s:cascade_del
    amenu 65.3 Fa&vourites.&Remove.Dummy <Nop>
  else
    amenu 65.2 Fa&vourites.&Remove\ current\ file :call <SID>RemoveThisFile(@%)<CR>
  endif

  if filereadable($FAVOURITES)
    sp $FAVOURITES|set nobl
    let s=@/
    g/\S/call <SID>AddThisFile(getline('.'))
    let @/=s
    q
    silent! aunmenu Fa&vourites.&Remove.Dummy
  endif
endf


silent! call <SID>Init()
