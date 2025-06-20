# Comando para Desinstalar o Plugin manai-vim

Para desinstalar o plugin manai-vim que foi instalado via script, você pode usar os seguintes comandos dependendo do seu gerenciador de plugins:

## 1. Se você usa Vim-Plug (gerenciador mais comum)

```bash
# Edite seu arquivo .vimrc ou init.vim
vim ~/.vimrc  # ou ~/.config/nvim/init.vim

# Remova ou comente a linha do plugin:
# Plug 'ruscorreia/manai-vim-plugin'

# Depois execute no Vim:
:PlugClean
```

## 2. Remoção manual completa

```bash
# Remova os arquivos do plugin
rm -rf ~/.vim/plugged/manai-vim-plugin  # Para Vim-Plug
rm -rf ~/.local/share/nvim/site/pack/*/manai-vim-plugin  # Para Neovim

# Remova as configurações relacionadas do seu .vimrc/init.vim
# Procure por 'manai' no seu arquivo de configuração e remova
```

## 3. Se foi instalado em outro local

Para ver onde o plugin foi instalado:
```bash
find ~ -type d -name "manai-vim-plugin" 2>/dev/null
```

Depois remova o diretório encontrado.

## 4. Remover configurações específicas

Para remover completamente todas as configurações:
```bash
# Remova o arquivo de configuração (se existir)
rm -f ~/.config/manai/config.json

# Remova variáveis relacionadas do seu .vimrc/init.vim
# Procure por 'g:manai_' e remova essas linhas
```

Observação: O script de instalação não costuma criar desinstaladores automáticos, então a remoção precisa ser feita manualmente como descrito acima.