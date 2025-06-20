#!/bin/bash

# Script de instalação do plugin manai-vim para Vim/Neovim (VERSÃO CORRIGIDA)
echo "Instalando manai-vim..."

# Verifica se curl está disponível
if ! command -v curl &> /dev/null; then
    echo "ERRO: curl não encontrado. Instale curl primeiro."
    exit 1
fi

# Verifica se o vim-plug está instalado
check_vim_plug() {
  if [ ! -f "$HOME/.vim/autoload/plug.vim" ] && \
     [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
    echo "vim-plug não encontrado. Instalando..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    
    if command -v nvim &> /dev/null; then
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
      echo "Arquivo de configuração criado em ~/.config/manai/config.json"
    fi
  fi
}

# Adiciona configuração ao vimrc
update_vimrc() {
  local vimrc_file="$HOME/.vimrc"
  local nvim_dir="$HOME/.config/nvim"
  
  # Para Neovim
  if command -v nvim &> /dev/null; then
    if [ -f "$nvim_dir/init.vim" ]; then
      vimrc_file="$nvim_dir/init.vim"
    elif [ -f "$nvim_dir/init.lua" ]; then
      echo "AVISO: Detectado init.lua. Configuração manual necessária."
      echo "Adicione a configuração manualmente ao seu init.lua"
      return
    elif [ -f "$HOME/.vimrc" ]; then
      vimrc_file="$HOME/.vimrc"
    else
      mkdir -p "$nvim_dir"
      vimrc_file="$nvim_dir/init.vim"
      touch "$vimrc_file"
    fi
  fi

  # Verifica se a configuração já existe
  if ! grep -q "manai-vim" "$vimrc_file" 2>/dev/null; then
    echo "Atualizando $vimrc_file..."
    cat <<EOF >> "$vimrc_file"

" Configuração do manai-vim (CORRIGIDA)
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/ruscorreia/manai-vim-plugin.git'
call plug#end()

" Configurações do manai-vim
" let g:manai_api_key = 'SUA_CHAVE_DA_API_AQUI'  " Opcional - já tem padrão
let g:manai_theme = 'material'  " temas disponíveis: material, dracula, nord

" Mapeamentos recomendados
nmap <leader>ma :Manai 
vmap <leader>ma :ManaiVisual<CR>
nmap <leader>mw :ManAIOpen<CR>
EOF
  else
    echo "Configuração já existe em $vimrc_file"
  fi
}

# Instala o plugin
install_plugin() {
  if command -v nvim &> /dev/null; then
    echo "Instalando plugin para Neovim..."
    nvim +PlugInstall +qall
  elif command -v vim &> /dev/null; then
    echo "Instalando plugin para Vim..."
    vim +PlugInstall +qall
  else
    echo "ERRO: Nem Vim nem Neovim encontrados!"
    exit 1
  fi
}

# Testa a instalação
test_installation() {
  echo "Testando instalação..."
  if command -v nvim &> /dev/null; then
    nvim -c 'ManAIConfig' -c 'q' 2>/dev/null && echo "✓ Plugin carregado com sucesso!"
  else
    vim -c 'ManAIConfig' -c 'q' 2>/dev/null && echo "✓ Plugin carregado com sucesso!"
  fi
}

# Fluxo principal
echo "=== Instalação do ManAI Vim Plugin ==="
check_vim_plug
create_config_dir
update_vimrc
install_plugin
test_installation

echo ""
echo "=== Instalação completa! ==="
echo "1. O plugin já está configurado com uma API key padrão"
echo "2. Edite ~/.config/manai/config.json para adicionar seu token (opcional)"
echo "3. Comandos disponíveis:"
echo "   :Manai <pergunta>     - Faz uma pergunta"
echo "   :ManaiVisual          - Analisa texto selecionado"
echo "   :ManAIConfig          - Mostra configuração atual"
echo "   :ManAIOpen            - Abre janela dedicada"
echo "4. Mapeamentos padrão:"
echo "   <leader>ma            - Comando Manai"
echo "   <leader>mw            - Abre janela ManAI"

