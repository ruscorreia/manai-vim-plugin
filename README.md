# manai-vim

![ManAI Vim Demo](demo.gif) *Exemplo de uso do plugin*

Plugin Vim/Neovim para integração com a API ManAI, proporcionando acesso direto ao assistente de IA diretamente do seu editor.

## ✨ Funcionalidades

- Consulta rápida ao ManAI via comando `:manai`
- Suporte a seleção visual (`:manaiVisual`)
- Janela dedicada com syntax highlighting
- Autenticação automática via arquivo de configuração
- Multi-idioma (pt, en, es, fr, de)
- Suporte a threads de conversação
- Interface visual personalizável

## 📦 Instalação

### Requisitos
- Vim (8.0+) ou Neovim (0.5+)
- [vim-plug](https://github.com/junegunn/vim-plug) (ou outro gerenciador de plugins)

### Via vim-plug
Adicione ao seu vimrc/init.vim:

```vim
call plug#begin()
Plug 'https://github.com/seu-usuario/manai-vim.git'
call plug#end()

" Configurações opcionais
let g:manai_api_key = 'SUA_CHAVE_API'
let g:manai_theme = 'material'  " temas: material, dracula, nord