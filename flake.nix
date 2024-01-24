{
  description = "Vim Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = import nixpkgs {
        inherit system;
      };

      my_vim = pkgs.vim_configurable.customize {
        name = "vim";

        vimrcConfig.packages.myVimPackage = {
          start = [
            pkgs.vimPlugins.vim-colors-solarized
            pkgs.vimPlugins.vim-lsp
            pkgs.vimPlugins.vim-airline
            pkgs.vimPlugins.vim-airline-themes
            pkgs.vimPlugins.nerdtree
            pkgs.vimPlugins.vim-nerdtree-tabs
          ];
        };

        vimrcConfig.customRC= ''
          set nocompatible
          set visualbell
          set backspace=indent,eol,start
          set foldlevel=99
          set nomodeline
          set number
          set expandtab
          set tabstop=4
          set shiftwidth=4
          set smarttab
          set autoindent
          set fileencodings=ucs-bom,utf-8,latin1
          set mouse=a
          set encoding=utf-8

          " solariaed dark
          set background=dark
          colorscheme solarized

          " start NERDTree
          autocmd VimEnter * NERDTree | wincmd p

          " enable syntax highlighting
          syntax on
          filetype plugin indent on

          if executable('clangd')
            autocmd User lsp_setup call lsp#register_server({
              \ 'name': 'clangd',
              \ 'cmd': ['clangd', '--clang-tidy', '--enable-config'],
              \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
              \ })
          endif

          if executable('rust-analyzer')
            autocmd User lsp_setup call lsp#register_server({
              \ 'name': 'rust-analyzer',
              \ 'cmd': ['rust-analyzer'],
              \ 'allowlist': ['rust'],
              \ 'initialization_options': {
              \   'cargo': {
              \       'buildScripts': {
              \           'enable': v:true,
              \         },
              \       'procMacro': {
              \           'enable': v:true,
              \        },
              \    },
              \   'rust-analyzer': {
              \       'check': {
              \           'command': 'clippy'
              \        }
              \   }
              \   }
              \ })
          endif

          function! s:on_lsp_buffer_enabled() abort
            setlocal omnifunc=lsp#complete
            if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
            set foldmethod=expr
              \ foldexpr=lsp#ui#vim#folding#foldexpr()
              \ foldtext=lsp#ui#vim#folding#foldtext()
          endfunction

          autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
          '';
      };
    in {
      packages = {
        default = my_vim;
      };

      apps.default = flake-utils.lib.mkApp {
        drv = my_vim;
      };
  });
}
