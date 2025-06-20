" manai-vim - Plugin de integração com ManAI para Vim/Neovim
" Version: 1.2.0 (Corrigido)
" Author: Rui Correia
" License: MIT

if exists('g:loaded_manai_vim') || &compatible
  finish
endif
let g:loaded_manai_vim = 1

" Configurações padrão
let g:manai_api_url = get(g:, 'manai_api_url', 'https://manai-agent-function-app.azurewebsites.net/api')
let g:manai_api_key = get(g:, 'manai_api_key', '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA==')
let g:manai_token = get(g:, 'manai_token', '')
let g:manai_theme = get(g:, 'manai_theme', 'material')
let g:manai_max_tokens = get(g:, 'manai_max_tokens', 1500)
let g:manai_enable_floating = get(g:, 'manai_enable_floating', has('nvim') ? 1 : 0)
let g:manai_config_file = get(g:, 'manai_config_file', expand('~/.config/manai/config.json'))

" Cores e tema
function! s:SetupHighlights()
  if g:manai_theme == 'material'
    highlight ManAITitle guifg=#FFA500 gui=bold ctermfg=214 cterm=bold
    highlight ManAIQuestion guifg=#4FC3F7 ctermfg=81
    highlight ManAIAnswer guifg=#AED581 ctermfg=150
    highlight ManAIError guifg=#FF5252 ctermfg=203
    highlight ManAIStatus guifg=#9575CD ctermfg=140
  elseif g:manai_theme == 'dracula'
    highlight ManAITitle guifg=#FF79C6 gui=bold ctermfg=212 cterm=bold
    highlight ManAIQuestion guifg=#8BE9FD ctermfg=117
    highlight ManAIAnswer guifg=#50FA7B ctermfg=84
    highlight ManAIError guifg=#FF5555 ctermfg=203
    highlight ManAIStatus guifg=#BD93F9 ctermfg=141
  else " nord
    highlight ManAITitle guifg=#D08770 gui=bold ctermfg=173 cterm=bold
    highlight ManAIQuestion guifg=#88C0D0 ctermfg=110
    highlight ManAIAnswer guifg=#A3BE8C ctermfg=144
    highlight ManAIError guifg=#BF616A ctermfg=131
    highlight ManAIStatus guifg=#B48EAD ctermfg=139
  endif
endfunction

" Carrega configurações do arquivo JSON
function! s:LoadConfig()
  if filereadable(g:manai_config_file)
    try
      let config_content = join(readfile(g:manai_config_file), "\n")
      " Implementação simples de parsing JSON sem dependências
      let token_match = matchstr(config_content, '"token":\s*"\zs[^"]*\ze"')
      if !empty(token_match)
        let g:manai_token = token_match
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
  elseif a:type == 'success'
    echohl ManAIAnswer
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

" Função para fazer requisições HTTP sem dependências externas
function! s:HttpRequest(url, data, headers)
  " Implementação usando curl como fallback
  let temp_file = tempname()
  let data_file = tempname()
  
  " Escreve dados JSON no arquivo temporário
  let json_data = '{"Question": "' . escape(a:data.Question, '"') . '", "language": "' . a:data.language . '"}'
  call writefile([json_data], data_file)
  
  " Monta comando curl
  let curl_cmd = 'curl -s -X POST'
  let curl_cmd .= ' -H "Content-Type: application/json"'
  
  " Adiciona headers de autorização se disponível
  if has_key(a:headers, 'Authorization')
    let curl_cmd .= ' -H "Authorization: ' . a:headers.Authorization . '"'
  endif
  
  let curl_cmd .= ' -d @' . data_file
  let curl_cmd .= ' "' . a:url . '"'
  let curl_cmd .= ' > ' . temp_file . ' 2>/dev/null'
  
  " Executa requisição
  call system(curl_cmd)
  
  " Lê resposta
  let response = ''
  if filereadable(temp_file)
    let response = join(readfile(temp_file), "\n")
  endif
  
  " Limpa arquivos temporários
  call delete(temp_file)
  call delete(data_file)
  
  return response
endfunction

" Função para parsing simples de JSON
function! s:ParseJsonResponse(json_string)
  let result = {}
  
  " Extrai campo 'answer'
  let answer_match = matchstr(a:json_string, '"answer":\s*"\zs[^"]*\ze"')
  if !empty(answer_match)
    let result.answer = answer_match
  endif
  
  " Extrai campo 'error'
  let error_match = matchstr(a:json_string, '"error":\s*"\zs[^"]*\ze"')
  if !empty(error_match)
    let result.error = error_match
  endif
  
  return result
endfunction

" Função principal de requisição
function! s:ManaiAsk(query, ...)
  if empty(g:manai_api_key)
    call s:ShowMessage('error', 'Chave da API não configurada. Use :ManAISetAPIKey')
    return ''
  endif

  " Carrega token do arquivo de configuração se não estiver definido
  if empty(g:manai_token)
    call s:LoadConfig()
  endif

  let lang = get(a:, 1, 'pt')
  let thread = get(a:, 2, '')
  
  call s:ShowMessage('info', 'Enviando pergunta para ManAI...')
  
  let url = g:manai_api_url . '/ManaiAgentHttpTrigger?code=' . g:manai_api_key
  let data = {
        \ 'Question': a:query,
        \ 'language': lang
        \ }
  
  if !empty(thread)
    let data['threadId'] = thread
  endif

  let headers = {}
  if !empty(g:manai_token)
    let headers['Authorization'] = 'Bearer ' . g:manai_token
  endif

  try
    let response_json = s:HttpRequest(url, data, headers)
    let response = s:ParseJsonResponse(response_json)

    if has_key(response, 'error')
      call s:ShowMessage('error', response.error)
      return ''
    elseif has_key(response, 'answer')
      call s:ShowMessage('success', 'Resposta recebida!')
      return response.answer
    else
      call s:ShowMessage('error', 'Resposta inválida da API')
      return ''
    endif
  catch /.*/
    call s:ShowMessage('error', 'Erro na requisição: ' . v:exception)
    return ''
  endtry
endfunction

" Interface do usuário
function! s:ManaiOpenWindow()
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

function! s:ManaiShowResponse(response)
  if empty(a:response)
    return
  endif
  
  call s:ManaiOpenWindow()
  
  " Adiciona cabeçalho
  call append(0, ['# Resposta do ManAI', '', '🤖 ' . a:response, ''])
  
  " Remove linha vazia inicial
  normal! ggdd
  
  " Posiciona cursor no início
  normal! gg
endfunction

" Comandos do usuário (CORRIGIDOS - nomes com maiúscula)
command! -nargs=1 -complete=customlist,s:CompleteLanguages Manai call s:ManaiShowResponse(s:ManaiAsk(<q-args>))
command! -range ManaiVisual call s:ManaiShowResponse(s:ManaiAsk(s:GetVisualSelection()))
command! -nargs=1 ManAISetAPIKey let g:manai_api_key = <q-args> | call s:ShowMessage('success', 'API Key configurada')
command! -nargs=1 ManAISetToken let g:manai_token = <q-args> | call s:ShowMessage('success', 'Token configurado')
command! ManAIOpen call s:ManaiOpenWindow()
command! ManAIConfig echo 'URL: ' . g:manai_api_url . "\nAPI Key: " . (empty(g:manai_api_key) ? 'Não configurada' : 'Configurada') . "\nToken: " . (empty(g:manai_token) ? 'Não configurado' : 'Configurado') . "\nTema: " . g:manai_theme

function! s:CompleteLanguages(ArgLead, CmdLine, CursorPos)
  return filter(['pt', 'en', 'es', 'fr', 'de'], 'v:val =~ "^" . a:ArgLead')
endfunction

" Mapeamentos sugeridos
if !hasmapto('<Plug>ManaiAsk')
  nmap <silent> <Leader>ma :Manai 
  vmap <silent> <Leader>ma :ManaiVisual<CR>
  nmap <silent> <Leader>mw :ManAIOpen<CR>
endif

" Autocomandos para janela ManAI
augroup ManAIWindow
  autocmd!
  autocmd BufEnter *.manai setlocal syntax=markdown
  autocmd BufEnter *.manai setlocal conceallevel=2
  autocmd BufEnter *.manai setlocal concealcursor=nc
  autocmd FileType manai setlocal syntax=markdown
augroup END

" Sintaxe personalizada
if has('syntax')
  syntax match ManAITitle /^# .*/ containedin=manai
  syntax match ManAIQuestion /^❓ .*/ containedin=manai
  syntax match ManAIAnswer /^🤖 .*/ containedin=manai
  syntax match ManAIError /^⚠️ .*/ containedin=manai
endif

" Inicialização
call s:SetupHighlights()
call s:LoadConfig()

" Mensagem de carregamento
call s:ShowMessage('info', 'Plugin ManAI carregado com sucesso!')

