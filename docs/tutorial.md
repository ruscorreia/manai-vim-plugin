# Tutorial Completo do manai-vim

## 🔧 Configuração Inicial

1. **Instale as dependências**:
   ```bash
   # Para requisições HTTP (se necessário)
   pip install requests
   ```

## 💡 Uso Avançado

### 1. Consultas com Contexto
Mantenha uma conversa com thread ID:
```vim
:let g:manai_thread = 'THREAD_ID'
:manai "Continue a partir da ideia anterior"
```

### 2. Multi-idiomas
Mude o idioma da resposta:
```vim
:manai "Explain closures in JavaScript" en
```

### 3. Integração com Buffers
Envie o conteúdo do buffer atual:
```vim
:%yank
:manai "Analise este código: " . @"
```

### 4. Comandos Úteis
| Comando            | Descrição                          |
|--------------------|-----------------------------------|
| `:ManAIConfig`     | Mostra configuração atual         |
| `:ManAISetAPIKey`  | Define sua chave API              |
| `:ManAISetToken`   | Altera token JWT manualmente      |

## 🎨 Personalização

### Cores Personalizadas
Adicione ao seu vimrc:
```vim
highlight ManAIQuestion guifg=#FF79C6
highlight ManAIAnswer guifg=#50FA7B
```

### Keybindings Recomendados
```vim
" Consulta rápida
nmap <leader>mq :manai 

" Consulta com texto selecionado
vmap <leader>mq y:manai <C-r>"<CR>

" Janela dedicada
nmap <leader>mw :ManAIOpen<CR>
```

## 🐛 Solução de Problemas

### Erro: "Chave da API não configurada"
1. Verifique se definiu:
   ```vim
   let g:manai_api_key = 'sua_chave'
   ```
2. Confira se o arquivo de configuração existe

### Respostas truncadas
Aumente o limite:
```vim
let g:manai_max_tokens = 3000
```

### Problemas com JSON
Instale o parser adequado:
```bash
pip install demjson
```

## 🤝 Contribuição
1. Faça fork do projeto
2. Crie sua branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request
```

Estes arquivos fornecem:
1. **README.md**: Visão geral e instruções básicas de instalação
2. **LICENSE**: Termos de uso MIT padrão
3. **TUTORIAL.md**: Guia completo com:
   - Configuração detalhada
   - Uso avançado
   - Personalização
   - Solução de problemas
   - Como contribuir

Todos seguem boas práticas de documentação para projetos open-source.