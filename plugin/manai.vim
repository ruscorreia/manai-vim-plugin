" manai-vim - Plugin de integração com ManAI para Vim/Neovim
" Version: 1.1.0
" Author: Seu Nome
" License: MIT

if exists('g:loaded_manai_vim') || &compatible
  finish
endif
let g:loaded_manai_vim = 1

" Configurações padrão
let g:manai_api_url = get(g:, 'manai_api_url', 'https://manai-agent-function-app.azurewebsites.net/api')
let g:manai_api_key = get(g:, 'manai_api_key', '')
let g:manai_token = get(g:, 'manai_token', '')
let g:manai_theme = get(g:, 'manai_theme', 'material')
let g:manai_max_tokens = get(g:, 'manai_max_tokens', 1500)
let g:manai_enable_floating = get(g:, 'manai_enable_floating', has('nvim') ? 1 : 0)
let g:manai_config_file = get(g:, 'manai_config_file', expand('~/.config/manai/config.json'))

" Cores e tema
highlight ManAITitle guifg=#FFA500 gui=bold
highlight ManAIQuestion guifg=#4FC3F7
highlight ManAIAnswer guifg=#AED581
highlight ManAIError guifg=#FF5252
highlight ManAIStatus guifg=#9575CD

" Carrega configurações do arquivo JSON
function! s:LoadConfig()
  if filereadable(g:manai_config_file)
    try
      let config = json_decode(join(readfile(g:manai_config_file), "\n"))
      if has_key(config, 'token')
        let g:manai_token = config.token
      endif
    catch /.*/
      call s:ShowMessage('error', 'Erro ao ler arquivo de configuração: ' . v:exception)
    endtry
  endif
endfunction

" Funções utilitárias
function! s:ShowMessage(type, message)
  if a:type == 'error'
    echohl ManAIError
    echomsg '[ManAI] ERRO: ' . a:message
    echohl None
  elseif a:type == 'info'
    echohl ManAIStatus
    echomsg '[ManAI] ' . a:message
    echohl None
  endif
endfunction

function! s:GetVisualSelection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  if len(lines) == 0
    return ''
  endif
  let lines[-1] = lines[-1][: col2 - 2]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

" Função principal de requisição
function! manai#Ask(query, ...)
  if empty(g:manai_api_key)
    call s:ShowMessage('error', 'Chave da API não configurada. Use :ManAISetAPIKey')
    return
  endif

  " Carrega token do arquivo de configuração se não estiver definido
  if empty(g:manai_token)
    call s:LoadConfig()
  endif

  let lang = get(a:, 1, 'pt')
  let thread = get(a:, 2, '')
  
  let url = g:manai_api_url . '/ManaiAgentHttpTrigger?code=' . g:manai_api_key
  let data = {
        \ 'Question': a:query,
        \ 'language': lang
        \ }
  
  if !empty(thread)
    let data['threadId'] = thread
  endif

  if !empty(g:manai_token)
    let headers = { 'Authorization': 'Bearer ' . g:manai_token }
  else
    let headers = {}
  endif

  let response = webapi#json#decode(webapi#http#post(url, data, headers).content)

  if has_key(response, 'error')
    call s:ShowMessage('error', response.error)
    return ''
  endif

  return response.answer
endfunction

" Interface do usuário
function! manai#OpenWindow()
  if g:manai_enable_floating && has('nvim')
    call s:CreateFloatingWindow()
  else
    call s:CreateSplitWindow()
  endif
endfunction

function! s:CreateFloatingWindow()
  let width = min([80, &columns - 4])
  let height = min([20, &lines - 4])
  let row = (&lines - height) / 2
  let col = (&columns - width) / 2

  let opts = {
        \ 'relative': 'editor',
        \ 'width': width,
        \ 'height': height,
        \ 'col': col,
        \ 'row': row,
        \ 'anchor': 'NW',
        \ 'style': 'minimal',
        \ 'border': 'single'
        \ }

  let buf = nvim_create_buf(v:false, v:true)
  let win = nvim_open_win(buf, v:true, opts)

  call setbufvar(buf, '&filetype', 'manai')
  call setbufvar(buf, '&buftype', 'nofile')
  call setbufvar(buf, '&bufhidden', 'wipe')
  call setbufvar(buf, '&swapfile', 0)

  return buf
endfunction

function! s:CreateSplitWindow()
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  setlocal filetype=manai
  setlocal nonumber norelativenumber
  setlocal winfixheight
  resize 10

  return bufnr('%')
endfunction

" Comandos do usuário
command! -nargs=1 -complete=customlist,manai#CompleteLanguages manai call manai#Ask(<q-args>)
command! -range manaiVisual call manai#Ask(s:GetVisualSelection())
command! -nargs=1 ManAISetAPIKey let g:manai_api_key = <q-args>
command! -nargs=1 ManAISetToken let g:manai_token = <q-args>
command! ManAIOpen call manai#OpenWindow()
command! ManAIConfig echo 'URL: ' . g:manai_api_url . "\nAPI Key: " . (empty(g:manai_api_key) ? 'Não configurada' : '*****') . "\nToken: " . (empty(g:manai_token) ? 'Não configurado' : '*****')

function! manai#CompleteLanguages(ArgLead, CmdLine, CursorPos)
  return ['pt', 'en', 'es', 'fr', 'de']
endfunction

" Mapeamentos sugeridos
if !hasmapto('<Plug>ManaiAsk')
  nmap <silent> <Leader>ma :manai 
  vmap <silent> <Leader>ma :manaiVisual<CR>
endif

" Autocomandos para janela ManAI
augroup ManAIWindow
  autocmd!
  autocmd BufEnter manai setlocal syntax=markdown
  autocmd BufEnter manai setlocal conceallevel=2
  autocmd BufEnter manai setlocal concealcursor=nc
augroup END

" Sintaxe personalizada
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif

syntax match ManAITitle /^# .*/ containedin=manai
syntax match ManAIQuestion /^❓ .*/ containedin=manai
syntax match ManAIAnswer /^🤖 .*/ containedin=manai
syntax match ManAIError /^⚠️ .*/ containedin=manai

" Carrega configuração automaticamente ao iniciar
call s:LoadConfig()