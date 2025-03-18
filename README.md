#ReadMe
This repo contains my setup for tmux and neovim.

Clone the repo to any directory and execute setup.sh. 

To install packages use 
```setup.sh --install packages``` 
This will install both system packages and mason packages for nvim.

To add new packages to the setup script, just add the name of the apt package to 
the packages or mason_packages list in 
```scripts/install_packages.sh```

## Additional Documentation
See [keybinds.md](keybinds.md) for keybinds.
