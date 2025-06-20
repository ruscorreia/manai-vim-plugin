#!/bin/bash

# Script de instalação do plugin manai-vim para Vim/Neovim
echo "Instalando manai-vim..."

# Verifica se o vim-plug está instalado
check_vim_plug() {
  if [ ! -f "$HOME/.vim/autoload/plug.vim" ] && \
     [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "vim-plug não encontrado. Instalando..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    
    if [ -n "$(which nvim)" ]; then
      curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
  fi
}

# Cria diretório de configuração se não existir
create_config_dir() {
  if [ ! -d "$HOME/.config/manai" ]; then
    echo "Criando diretório de configuração..."
    mkdir -p "$HOME/.config/manai"
    # Cria arquivo de configuração vazio se não existir
    if [ ! -f "$HOME/.config/manai/config.json" ]; then
      echo '{"token": "", "user": {}}' > "$HOME/.config/manai/config.json"
    fi
  fi
}

# Adiciona configuração ao vimrc
update_vimrc() {
  local vimrc_file="$HOME/.vimrc"
  local nvim_dir="$HOME/.config/nvim"
  
  # Para Neovim
  if [ -n "$(which nvim)" ]; then
    if [ -f "$nvim_dir/init.vim" ]; then
      vimrc_file="$nvim_dir/init.vim"
    elif [ -f "$HOME/.vimrc" ]; then
      vimrc_file="$HOME/.vimrc"
    else
      vimrc_file="$nvim_dir/init.vim"
      touch "$vimrc_file"
    fi
  fi

  # Verifica se a configuração já existe
  if ! grep -q "manai-vim" "$vimrc_file"; then
    echo "Atualizando $vimrc_file..."
    cat <<EOF >> "$vimrc_file"

" Configuração do manai-vim
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/seu-usuario/manai-vim.git'
call plug#end()

" Configurações do manai-vim
let g:manai_api_key = 'SUA_CHAVE_DA_API_AQUI'
let g:manai_theme = 'material'  " temas disponíveis: material, dracula, nord
EOF
  fi
}

# Instala o plugin
install_plugin() {
  if [ -n "$(which nvim)" ]; then
    echo "Instalando plugin para Neovim..."
    nvim +PlugInstall +qall
  else
    echo "Instalando plugin para Vim..."
    vim +PlugInstall +qall
  fi
}

# Fluxo principal
check_vim_plug
create_config_dir
update_vimrc
install_plugin

echo "Instalação completa!"
echo "1. Edite ~/.config/manai/config.json para adicionar seu token"
echo "2. Edite seu vimrc/init.vim para configurar sua API key"
echo "3. Comandos disponíveis: :manai, :manaiVisual, :ManAIConfig"