" manai-vim - Plugin de integração com ManAI para Vim/Neovim
" Version: 1.2.0 (Corrigido)
" Author: Rosario Correia
" License: MIT
" Configuração de debug

let g:manai_debug = get(g:, 'manai_debug', 0)

command! ManAIToggleDebug let g:manai_debug = !g:manai_debug | call s:ShowMessage('info', 'Modo debug ' . (g:manai_debug ? 'ativado' : 'desativado'))

if exists('g:loaded_manai_vim') || &compatible
  finish
endif
let g:loaded_manai_vim = 1

" Verifica se curl está instalado
if !executable('curl')
  echohl ErrorMsg
  echomsg 'manai-vim requer curl instalado no sistema'
  echohl None
  finish
endif

" Configurações padrão
let g:manai_api_url = get(g:, 'manai_api_url', 'https://manai-agent-function-app.azurewebsites.net/api')
let g:manai_api_key = get(g:, 'manai_api_key', '58H0KD8feP9x2e6uqY1wkwW-6MqwrNkWI6U4-jdsSa5EAzFuACdqNA==')
let g:manai_token = get(g:, 'manai_token', '')
let g:manai_theme = get(g:, 'manai_theme', 'material')
let g:manai_max_tokens = get(g:, 'manai_max_tokens', 40000)
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
    
    " Log detalhado para debug
    if exists('g:manai_debug') && g:manai_debug
      let log_file = expand('~/.manai_vim.log')
      let log_msg = strftime('%Y-%m-%d %H:%M:%S') . ' - ERROR: ' . a:message
      call writefile([log_msg], log_file, 'a')
    endif
  endif
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
  let temp_file = tempname()
  let data_file = tempname()
  
  " Escreve dados JSON no arquivo temporário
  let json_data = json_encode(a:data)
  call writefile([json_data], data_file)
  
  " Monta comando curl com timeout
  let curl_cmd = 'curl -s -X POST --max-time 30'
  let curl_cmd .= ' -H "Content-Type: application/json"'
  
  " Adiciona headers
  for [key, value] in items(a:headers)
    let curl_cmd .= ' -H "' . key . ': ' . escape(value, '"') . '"'
  endfor
  
  let curl_cmd .= ' -d @' . data_file
  let curl_cmd .= ' "' . a:url . '"'
  let curl_cmd .= ' > ' . temp_file . ' 2>&1'
  
  " Executa requisição
  let exit_code = system(curl_cmd)
  
  " Verifica se houve erro no comando curl
  if v:shell_error != 0
    call delete(temp_file)
    call delete(data_file)
    throw 'Erro na requisição HTTP (curl): ' . exit_code
  endif
  
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
  if empty(a:json_string)
    return {'error': 'Resposta vazia da API'}
  endif

  " Primeiro tenta usar json_decode se disponível
  if exists('*json_decode')
    try
      let cleaned_json = s:CleanApiResponse(a:json_string)
      let result = json_decode(cleaned_json)
      
      " Verifica se o parsing foi bem-sucedido
      if type(result) == v:t_dict && (has_key(result, 'answer') || has_key(result, 'error'))
        return result
      endif
    catch /.*/
      " Fallback para parsing manual se json_decode falhar
    endtry
  endif

  " Fallback robusto para parsing manual
  let result = {}
  
  " Padrões para tentar extrair a resposta
  let patterns = [
        \ '"answer":\s*"\(.\{-}\)"\s*[,}]',
        \ '"response":\s*"\(.\{-}\)"\s*[,}]',
        \ '"text":\s*"\(.\{-}\)"\s*[,}]',
        \ '"message":\s*"\(.\{-}\)"\s*[,}]'
        \ ]
  
  " Tenta cada padrão até encontrar uma correspondência
  for pattern in patterns
    let match = matchlist(a:json_string, pattern)
    if !empty(match) && !empty(match[1])
      let result.answer = substitute(match[1], '\\n', '\n', 'g')
      break
    endif
  endfor

  " Se não encontrou answer, procura por error
  if !has_key(result, 'answer')
    let error_patterns = [
          \ '"error":\s*"\(.\{-}\)"\s*[,}]',
          \ '"err":\s*"\(.\{-}\)"\s*[,}]',
          \ '"message":\s*"\(.\{-}\)"\s*[,}]'
          \ ]
    
    for pattern in error_patterns
      let match = matchlist(a:json_string, pattern)
      if !empty(match) && !empty(match[1])
        let result.error = substitute(match[1], '\\n', '\n', 'g')
        break
      endif
    endfor
  endif

  " Se ainda não encontrou nada, tenta pegar o texto entre aspas mais longo
  if !has_key(result, 'answer') && !has_key(result, 'error')
    let match = matchlist(a:json_string, '"\([^"]\{3,\}\)"')
    if !empty(match) && !empty(match[1])
      let result.answer = substitute(match[1], '\\n', '\n', 'g')
    endif
  endif

  " Fallback robusto para respostas muito longas
  if !has_key(result, 'answer') && !has_key(result, 'error')
    " Tenta pegar todo o conteúdo entre aspas
    let matches = matchlist(a:json_string, '"\(.*\)"')
    if !empty(matches) && len(matches) > 1
      let full_content = matches[1]
      let result.answer = substitute(full_content, '\\n', '\n', 'g')
    else
      " Se tudo falhar, retorna a resposta crua (pode ser markdown/plain text)
      let result.answer = a:json_string
    endif
  endif

  return result
endfunction

function! s:CleanApiResponse(response)
  " Remove caracteres problemáticos
  let cleaned = substitute(a:response, '[\x00-\x1F]', '', 'g')  " Remove todos os caracteres de controle
  let cleaned = substitute(cleaned, '\\"', '"', 'g')           " Remove escapes de aspas
  let cleaned = substitute(cleaned, '\\\\', '\\', 'g')         " Remove escapes de barras
  
  " Tenta extrair o JSON válido mesmo em respostas malformadas
  let json_start = stridx(cleaned, '{')
  let json_end = strridx(cleaned, '}')
  
  if json_start >= 0 && json_end > json_start
    let cleaned = strpart(cleaned, json_start, json_end - json_start + 1)
  endif
  
  return cleaned
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
    let raw_response = s:HttpRequest(url, data, headers)
    
    " Debug: Log da resposta bruta
    if exists('g:manai_debug') && g:manai_debug
      call writefile(['Raw API response:', raw_response], '/tmp/manai_debug.log', 'a')
    endif
    
    let response = s:ParseJsonResponse(raw_response)

    " Tratamento especial para respostas que não foram parseadas corretamente
    if empty(response) || (!has_key(response, 'answer') && !has_key(response, 'error'))
      " Tenta usar a resposta bruta como answer
      let cleaned_response = substitute(raw_response, '^[^{]*', '', '')
      let cleaned_response = substitute(cleaned_response, '[^}]*$', '', '')
      let cleaned_response = substitute(cleaned_response, '\\n', '\n', 'g')
      let response = {'answer': cleaned_response}
    endif

    if has_key(response, 'error')
      call s:ShowMessage('error', response.error)
      return ''
    elseif has_key(response, 'answer')
      call s:ShowMessage('success', 'Resposta recebida!')
      return response.answer
    else
      call s:ShowMessage('error', 'Resposta inválida da API: ' . raw_response)
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
  
  " Cria a janela
  let buf = s:ManaiOpenWindow()
  
  " Limpa o buffer
  silent %delete _
  
  " Configurações do buffer
  setlocal modifiable
  setlocal noreadonly
  
  " Adiciona cabeçalho e resposta formatada
  call append(0, ['# Resposta do ManAI. :q para sair', ''])
  
  " Processa a resposta para garantir quebra de linhas adequadas
  let response_lines = split(a:response, '\n')
  
  " Adiciona linhas ao buffer
  call setline(3, response_lines)
  
  " Remove linhas vazias extras no final
  while getline('$') == ''
    $delete _
  endwhile
  
  " Configurações finais do buffer
  setlocal nomodifiable
  setlocal readonly
  setlocal wrap
  setlocal linebreak
  
  " Posiciona cursor no início
  normal! gg

  " Ativa quebra de linha para melhor legibilidade
  setlocal wrap
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
