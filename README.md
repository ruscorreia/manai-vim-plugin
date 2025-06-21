# ManAI Vim Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Vim](https://img.shields.io/badge/Vim-8.0%2B-green.svg)](https://www.vim.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.5%2B-blue.svg)](https://neovim.io/)
[![Version](https://img.shields.io/badge/Version-1.2.0-brightgreen.svg)](https://github.com/ruscorreia/manai-vim-plugin/releases)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey.svg)](https://github.com/ruscorreia/manai-vim-plugin)

<div align="center">
  <h1>🤖 ManAI Vim Plugin</h1>
  <p><em>Integração inteligente com a API ManAI diretamente no seu editor favorito</em></p>
</div>

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Funcionalidades](#-funcionalidades)
- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Configuração](#-configuração)
- [Utilização](#-utilização)
- [Personalização](#-personalização)
- [Resolução de Problemas](#-resolução-de-problemas)
- [Contribuição](#-contribuição)
- [Licença](#-licença)
- [Agradecimentos](#-agradecimentos)

---

## 🎯 Sobre o Projeto

O **ManAI Vim Plugin** é uma extensão poderosa que integra a inteligência artificial do ManAI diretamente no Vim e Neovim. Este plugin permite-lhe fazer perguntas, analisar código, obter explicações e muito mais, sem sair do seu ambiente de desenvolvimento.

### ✨ Destaques

- 🚀 **Sem dependências externas** - Funciona apenas com curl
- 🎨 **Interface personalizável** - 3 temas visuais disponíveis
- 🌍 **Suporte multi-idioma** - Português, Inglês, Espanhol, Francês, Alemão
- 💬 **Conversas contextuais** - Suporte a threads de conversação
- 🔧 **Altamente configurável** - Múltiplas opções de personalização
- ⚡ **Performance otimizada** - Parsing JSON nativo e eficiente

---

## 🚀 Funcionalidades

### Comandos Principais

| Comando | Descrição | Exemplo de Uso |
|---------|-----------|----------------|
| `:Manai <pergunta>` | Faz uma pergunta ao ManAI | `:Manai Como funciona recursão em Python?` |
| `:ManaiVisual` | Analisa texto selecionado | Selecione código e execute o comando |
| `:ManAIOpen` | Abre janela dedicada | `:ManAIOpen` |
| `:ManAIConfig` | Mostra configuração atual | `:ManAIConfig` |
| `:ManAISetToken` | Define token personalizado | `:ManAISetToken seu_token_aqui` |

### Funcionalidades Avançadas

- ✅ **Consulta rápida** via comando `:Manai`
- ✅ **Análise de código** com seleção visual
- ✅ **Janela dedicada** com syntax highlighting
- ✅ **Autenticação automática** via ficheiro de configuração
- ✅ **Suporte multi-idioma** (pt, en, es, fr, de)
- ✅ **Threads de conversação** para contexto contínuo
- ✅ **Interface visual personalizável** com 3 temas
- ✅ **Janelas flutuantes** no Neovim
- ✅ **Modo debug** para resolução de problemas

---

## 📋 Requisitos

### Requisitos Obrigatórios

- **Vim** 8.0+ ou **Neovim** 0.5+
- **curl** (para requisições HTTP)
- **Sistema operativo**: Linux, macOS ou Windows

### Requisitos Opcionais

- [vim-plug](https://github.com/junegunn/vim-plug) (instalado automaticamente)
- Conta ManAI (para token personalizado)

### Verificação de Requisitos

```bash
# Verificar versão do Vim
vim --version | head -1

# Verificar versão do Neovim
nvim --version | head -1

# Verificar se curl está instalado
curl --version
```

---

## 📦 Instalação

### Instalação Automática (Recomendada)

A forma mais simples de instalar o plugin é através do script automático:

```bash
curl -fsSL https://raw.githubusercontent.com/ruscorreia/manai-vim-plugin/main/install.sh | bash
```

Este script irá:
1. Verificar e instalar dependências necessárias
2. Instalar o vim-plug se não estiver presente
3. Configurar automaticamente o seu `.vimrc` ou `init.vim`
4. Instalar o plugin
5. Criar ficheiros de configuração necessários

### Instalação Manual

#### 1. Instalar vim-plug (se necessário)

**Para Vim:**
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

**Para Neovim:**
```bash
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

#### 2. Configurar o Plugin

Adicione ao seu `~/.vimrc` (Vim) ou `~/.config/nvim/init.vim` (Neovim):

```vim
call plug#begin('~/.vim/plugged')
Plug 'ruscorreia/manai-vim-plugin'
call plug#end()

" Configurações básicas do ManAI
let g:manai_theme = 'material'  " Temas: material, dracula, nord
let g:manai_enable_floating = 1  " Janelas flutuantes (apenas Neovim)

" Mapeamentos recomendados
nmap <leader>ma :Manai 
vmap <leader>ma :ManaiVisual<CR>
nmap <leader>mw :ManAIOpen<CR>
```

#### 3. Instalar o Plugin

Execute no Vim/Neovim:
```vim
:PlugInstall
```

---

## ⚙️ Configuração

### Configuração Básica

O plugin funciona imediatamente após a instalação com configurações padrão. Para personalizar:

```vim
" Configurações opcionais no seu .vimrc/init.vim
let g:manai_theme = 'dracula'           " Tema visual
let g:manai_max_tokens = 2000           " Limite de tokens
let g:manai_enable_floating = 1         " Janelas flutuantes (Neovim)
```

### Ficheiro de Configuração

O plugin cria automaticamente `~/.config/manai/config.json`:

```json
{
  "token": "seu_token_opcional",
  "user": {},
  "preferences": {
    "theme": "material",
    "language": "pt"
  }
}
```

### Variáveis de Configuração Disponíveis

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `g:manai_theme` | `'material'` | Tema visual (material, dracula, nord) |
| `g:manai_max_tokens` | `40000` | Limite máximo de tokens |
| `g:manai_enable_floating` | `1` (Neovim) | Ativar janelas flutuantes |
| `g:manai_debug` | `0` | Modo debug para resolução de problemas |

---

## 🎯 Utilização

### Utilização Básica

#### 1. Fazer uma Pergunta Simples
```vim
:Manai Explica-me o que são closures em JavaScript
```

#### 2. Analisar Código Selecionado
1. Selecione o código em modo visual (`v` ou `V`)
2. Execute `:ManaiVisual`
3. O ManAI irá analisar o código selecionado

#### 3. Abrir Janela Dedicada
```vim
:ManAIOpen
```

### Utilização Avançada

#### Consultas Multi-idioma
```vim
:Manai "Explain Python decorators" en
:Manai "Explique les décorateurs Python" fr
:Manai "Erkläre Python-Dekorateure" de
```

#### Mapeamentos de Teclado

Os mapeamentos padrão são:

| Mapeamento | Modo | Função |
|------------|------|--------|
| `<leader>ma` | Normal | Comando Manai |
| `<leader>ma` | Visual | Análise de seleção |
| `<leader>mw` | Normal | Abrir janela ManAI |

#### Integração com Buffers

```vim
" Enviar conteúdo do buffer atual
:%yank
:Manai Analisa este código: <C-r>"

" Analisar função sob o cursor
:Manai Explica esta função: <C-r><C-w>
```

---

## 🎨 Personalização

### Temas Disponíveis

#### Material (Padrão)
- Cores vibrantes e modernas
- Excelente legibilidade
- Inspirado no Material Design

#### Dracula
- Tema escuro popular
- Cores roxas e rosas
- Perfeito para sessões noturnas

#### Nord
- Tema minimalista
- Cores frias e suaves
- Design limpo e profissional

### Personalizar Cores

```vim
" Personalizar cores do tema
highlight ManAITitle guifg=#FF6B6B gui=bold
highlight ManAIQuestion guifg=#4ECDC4
highlight ManAIAnswer guifg=#45B7D1
highlight ManAIError guifg=#FF5252
highlight ManAIStatus guifg=#96CEB4
```

### Mapeamentos Personalizados

```vim
" Mapeamentos alternativos
nmap <F5> :Manai 
nmap <F6> :ManAIOpen<CR>
vmap <F5> :ManaiVisual<CR>

" Consulta rápida com input
nmap <leader>mq :call input('Pergunta: ')<CR>:Manai <C-r>=input('')<CR>
```

---

## 🐛 Resolução de Problemas

### Problemas Comuns

#### Plugin Não Carrega

**Sintomas:** Comandos ManAI não são reconhecidos

**Soluções:**
1. Verificar se curl está instalado:
   ```bash
   curl --version
   ```

2. Testar sintaxe do plugin:
   ```vim
   :source ~/.vim/plugged/manai-vim-plugin/plugin/manai.vim
   ```

3. Verificar logs de erro:
   ```vim
   :messages
   ```

#### Erro de Requisição

**Sintomas:** "Erro na requisição HTTP"

**Soluções:**
1. Verificar conectividade:
   ```bash
   curl -I https://manai-agent-function-app.azurewebsites.net
   ```

2. Verificar configuração:
   ```vim
   :ManAIConfig
   ```

3. Testar com comando simples:
   ```vim
   :Manai teste
   ```

#### Comandos Não Encontrados

**Sintomas:** "E492: Not an editor command"

**Soluções:**
1. Recarregar plugin:
   ```vim
   :source ~/.vim/plugged/manai-vim-plugin/plugin/manai.vim
   ```

2. Verificar instalação:
   ```vim
   :PlugStatus
   ```

#### Respostas Truncadas

**Sintomas:** Respostas incompletas

**Soluções:**
1. Aumentar limite de tokens:
   ```vim
   let g:manai_max_tokens = 3000
   ```

2. Verificar configuração da API

### Modo Debug

Para ativar o modo debug:

```vim
:let g:manai_debug = 1
:ManAIToggleDebug
```

Os logs serão guardados em `~/.manai_vim.log`.

### Obter Ajuda

1. **Documentação:** Consulte este README
2. **Issues:** [GitHub Issues](https://github.com/ruscorreia/manai-vim-plugin/issues)
3. **Discussões:** [GitHub Discussions](https://github.com/ruscorreia/manai-vim-plugin/discussions)

---

## 📝 Changelog

### v1.2.0 (Atual - Corrigida)

#### ✅ Correções Implementadas
- **Comandos corrigidos** - Nomes com maiúscula obrigatória
- **Dependências removidas** - Sem necessidade do webapi-vim
- **Implementação própria** - Requisições HTTP nativas
- **Parsing JSON robusto** - Sem dependências externas
- **Tratamento de erros** - Validações e mensagens claras
- **Temas funcionais** - Material, Dracula e Nord implementados
- **API key incluída** - Funciona imediatamente após instalação
- **Script corrigido** - `install.sh` em vez de `nstall.sh`
- **Documentação atualizada** - README completo e detalhado

#### 🆕 Novas Funcionalidades
- Modo debug com logging detalhado
- Suporte a janelas flutuantes no Neovim
- Configuração via ficheiro JSON
- Mapeamentos de teclado configuráveis
- Syntax highlighting personalizado

### v1.1.0 (Original)
- Funcionalidades básicas
- Integração com webapi-vim
- Comandos e mapeamentos iniciais

---

## 🤝 Contribuição

Contribuições são muito bem-vindas! Este projeto segue as melhores práticas de desenvolvimento open-source.

### Como Contribuir

1. **Fork o projeto**
   ```bash
   git clone https://github.com/ruscorreia/manai-vim-plugin.git
   ```

2. **Crie uma branch para a sua funcionalidade**
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```

3. **Faça as suas alterações**
   - Siga as convenções de código existentes
   - Adicione testes se aplicável
   - Atualize a documentação

4. **Commit as suas mudanças**
   ```bash
   git commit -am 'Adiciona nova funcionalidade: descrição detalhada'
   ```

5. **Push para a branch**
   ```bash
   git push origin feature/nova-funcionalidade
   ```

6. **Abra um Pull Request**
   - Descreva as mudanças em detalhe
   - Referencie issues relacionadas
   - Aguarde revisão

### Diretrizes de Contribuição

- **Código:** Siga as convenções VimScript existentes
- **Commits:** Use mensagens descritivas em português
- **Testes:** Adicione testes para novas funcionalidades
- **Documentação:** Atualize README e comentários
- **Issues:** Use templates fornecidos

### Áreas que Precisam de Ajuda

- 🐛 Correção de bugs
- 📚 Melhoria da documentação
- 🌍 Traduções para outros idiomas
- ⚡ Otimizações de performance
- 🎨 Melhorias na interface
- 🧪 Testes automatizados

---

## 📄 Licença

Este projeto está licenciado sob a **Licença MIT** - consulte o ficheiro [LICENSE](LICENSE) para detalhes.

```
MIT License

Copyright (c) 2024 Rosario Correia

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Agradecimentos

- **Equipa ManAI** - Pela excelente API de inteligência artificial
- **Comunidade Vim/Neovim** - Pelo suporte e inspiração contínua
- **Contribuidores** - Por tornarem este projeto melhor
- **Utilizadores** - Por testarem e fornecerem feedback valioso

### Projetos Relacionados

- [ManAI](https://manai.pt) - Plataforma de inteligência artificial
- [Vim](https://www.vim.org/) - Editor de texto poderoso
- [Neovim](https://neovim.io/) - Vim modernizado
- [vim-plug](https://github.com/junegunn/vim-plug) - Gestor de plugins

---

<div align="center">
  <p>Feito com ❤️ por <a href="https://github.com/ruscorreia">Rosario Correia</a></p>
  <p>
    <a href="https://github.com/ruscorreia/manai-vim-plugin/stargazers">⭐ Star</a> •
    <a href="https://github.com/ruscorreia/manai-vim-plugin/issues">🐛 Report Bug</a> •
    <a href="https://github.com/ruscorreia/manai-vim-plugin/issues">💡 Request Feature</a>
  </p>
</div>

