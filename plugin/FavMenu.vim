" Author: Gergely Kontra <kgergely@mcl.hu>
" Version: 0.1
" Description:
"    Adds a new menu to vim
"    You can add your favourite files into it, and open them later by clicking
"    on the corresponding menu item.
"    The file list is persistent, data is stored in your $VIM/favourite.files
"    file.
"
" Installation: Drop it into your plugin directory
"
" History:
"    0.1: Initial release
"
" TODO:
"    $VIM/favourite.files should be a variable
"    :sp command should be variable too
"    Are all valid filenames escaped?
"
fu! <SID>AddThisFile(name)
  let fullname=fnamemodify(a:name,':p')
  let path=escape(fnamemodify(fullname,':p:h'),'\. #')
  let fn=escape(fnamemodify(fullname,':p:t'),'\. #')
  exe 'amenu Favourites.'.fn."<Tab>".path.' :sp '.escape(fullname,'#').'<CR>'
endf

fu! <SID>AddThisFilePermanent(name)
  call <SID>AddThisFile(a:name)
  let fullname=fnamemodify(a:name,':p')
  exe 'redir >> '.$VIM.'/favourite.files'
  echo fullname
  redir END
endf

fu! <SID>RemoveThisFile(name)
  let fullname=fnamemodify(a:name,':p')
  let path=escape(fnamemodify(fullname,':p:h'),'\. ')
  let fn=escape(fnamemodify(fullname,':p:t'),'\. ')
  exe 'silent! aunmenu Favourites.'.fn.'<Tab>'.path
  sp $VIM/favourite.files
  exe 'g@'. escape(fullname,'\. #').'@d'
  wq
endf

silent! aunmenu Favourites
amenu 65.1 Favourites.Add\ current\ file :silent call <SID>AddThisFilePermanent(@%)<CR>
amenu Favourites.Remove\ current\ file :call <SID>RemoveThisFile(@%)<CR>
amenu Favourites.-sep-	<nul>

fu! <SID>init()
  if filereadable($VIM.'/favourite.files')
    sp $VIM/favourite.files
    g/^.\+$/call <SID>AddThisFile(getline('.'))
    q
    noh
  endif
endf
silent call <SID>init()
