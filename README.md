# manai-vim (Versão Corrigida)

![ManAI Vim Demo](demo.gif) *Exemplo de uso do plugin*

Plugin Vim/Neovim para integração com a API ManAI, proporcionando acesso direto ao assistente de IA diretamente do seu editor.

## ✨ Requisitos

- Tem que ter o manai instalado   [manai](https://github.com/ruscorreia/manai.git)

- Login no manai anter de abrir o vim
```bash
$ manai --login
```

## ✨ Funcionalidades

- Consulta rápida ao ManAI via comando `:Manai`
- Suporte a seleção visual (`:ManaiVisual`)
- Janela dedicada com syntax highlighting
- Autenticação automática via arquivo de configuração
- Multi-idioma (pt, en, es, fr, de)
- Suporte a threads de conversação
- Interface visual personalizável com 3 temas
- **Sem dependências externas** - funciona apenas com curl

## 🔧 Correções Implementadas

Esta versão corrige os seguintes problemas da versão original:

- ✅ **Comandos com nomes válidos** - Agora começam com maiúscula
- ✅ **Sem dependência do webapi-vim** - Implementação própria com curl
- ✅ **Script de instalação corrigido** - `install.sh` em vez de `nstall.sh`
- ✅ **Melhor tratamento de erros** - Validações e mensagens claras
- ✅ **Temas funcionais** - Material, Dracula e Nord implementados
- ✅ **API key padrão incluída** - Funciona imediatamente após instalação
- ✅ **Parsing JSON próprio** - Sem dependências externas

## 📦 Instalação

### Instalação Automática (Recomendada)

```bash
curl -fsSL https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main/install.sh | bash
```

## 🚀 Uso

### Comandos Principais

| Comando | Descrição | Exemplo |
|---------|-----------|---------|
| `:Manai <pergunta>` | Faz uma pergunta ao ManAI | `:Manai Como funciona recursão?` |
| `:ManaiVisual` | Analisa texto selecionado | Selecione texto e execute |
| `:ManAIOpen` | Abre janela dedicada | `:ManAIOpen` |
| `:ManAIConfig` | Mostra configuração atual | `:ManAIConfig` |

### Mapeamentos Padrão

- `<leader>ma` - Comando Manai (modo normal e visual)
- `<leader>mw` - Abre janela ManAI

### Configuração Avançada

```vim
" Personalizar tema
let g:manai_theme = 'dracula'  " ou 'nord', 'material'

" Configurar idioma padrão
:Manai "Explain closures" en

" Usar token personalizado (opcional)
:ManAISetToken seu_token_jwt_aqui
```

### Instalação Manual

#### Requisitos
- Vim (8.0+) ou Neovim (0.5+)
- [vim-plug](https://github.com/junegunn/vim-plug) (instalado automaticamente)
- curl (para requisições HTTP)

#### Via vim-plug
Adicione ao seu vimrc/init.vim:

```vim
call plug#begin()
Plug 'https://github.com/ruscorreia/manai-vim-plugin.git'
call plug#end()

" Configurações opcionais
let g:manai_theme = 'material'  " temas: material, dracula, nord
let g:manai_enable_floating = 1  " janelas flutuantes no Neovim

" Mapeamentos recomendados
nmap <leader>ma :Manai 
vmap <leader>ma :ManaiVisual<CR>
nmap <leader>mw :ManAIOpen<CR>
```

Depois execute `:PlugInstall` no Vim.

## 🎨 Temas Disponíveis

### Material (Padrão)
- Cores vibrantes e modernas
- Boa legibilidade

### Dracula
- Tema escuro popular
- Cores roxas e rosas

### Nord
- Tema minimalista
- Cores frias e suaves

## 🔧 Configuração

### Arquivo de Configuração
O plugin cria automaticamente `~/.config/manai/config.json`:

```json
{
  "token": "seu_token_opcional",
  "user": {}
}
```

### Variáveis de Configuração

```vim
let g:manai_api_url = 'https://manai-agent-function-app.azurewebsites.net/api'
let g:manai_api_key = 'chave_padrao_incluida'
let g:manai_theme = 'material'
let g:manai_max_tokens = 1500
let g:manai_enable_floating = 1  " apenas Neovim
```

## 🐛 Solução de Problemas

### Plugin não carrega
```bash
# Verifique se curl está instalado
curl --version

# Teste a sintaxe do plugin
vim -u NONE -c 'source ~/.vim/plugged/manai-vim-plugin/plugin/manai.vim'
```

### Erro de requisição
```vim
" Verifique a configuração
:ManAIConfig

" Teste conectividade
:Manai "teste"
```

### Comandos não encontrados
```vim
" Recarregue o plugin
:source ~/.vim/plugged/manai-vim-plugin/plugin/manai.vim
```

## 📝 Changelog

### v1.2.0 (Corrigida)
- ✅ Corrigidos nomes de comandos (maiúscula obrigatória)
- ✅ Removida dependência do webapi-vim
- ✅ Implementação própria de requisições HTTP
- ✅ Parsing JSON nativo
- ✅ Melhor tratamento de erros
- ✅ Temas funcionais implementados
- ✅ API key padrão incluída
- ✅ Script de instalação corrigido
- ✅ Documentação atualizada

### v1.1.0 (Original)
- Funcionalidades básicas
- Integração com webapi-vim
- Comandos e mapeamentos

## 🤝 Contribuição

1. Faça fork do projeto
2. Crie sua branch (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## 📄 Licença

MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- Equipe ManAI pela API
- Comunidade Vim/Neovim
- Contribuidores do projeto

