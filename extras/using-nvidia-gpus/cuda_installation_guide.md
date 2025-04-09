# NVIDIA Driver & CUDA 12.2.2 Installation Guide (Ubuntu 20.04)

Setting up CUDA is always a challenge on Linux systems. This guide will walk you through installing the NVIDIA 535 drivers and CUDA 12.2.2, and setting up MLIR with GPU support in the same way I did this on my system. However, there is no guarentee that will work for you and there is always a risk that you mess up your display. So you have been warned.

## Step 1: Remove Existing NVIDIA Drivers and CUDA

Clean your system of any previously installed NVIDIA or CUDA components:

```bash
sudo apt-get purge nvidia*
sudo apt remove nvidia-*
sudo rm /etc/apt/sources.list.d/cuda*
sudo apt-get autoremove && sudo apt-get autoclean
sudo rm -rf /usr/local/cuda*
```

This will remove any Nvidia drivers installed. Ubuntu should fall back to the Nouveau drivers, but this is probably the riskiest part of this build

Reboot your machine after installation (may not be necessary):

`sudo reboot`

## Step 2: Install NVIDIA Driver (Version 535)

Use Ubuntu’s [built-in driver management](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/index.html) to install the correct driver:

`sudo ubuntu-drivers install nvidia:535`

Reboot your machine after installation:

`sudo reboot`

## Step 3: Install CUDA 12.2.2

[CUDA 12.2.2 Archive: CUDA Downloads (12.2.2)](https://developer.nvidia.com/cuda-12-2-2-download-archive?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=20.04&target_type=deb_local)

Add CUDA repository and install:

### Download and set up the repo pin
```
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
```

### Download the local CUDA repo installer
```
wget https://developer.download.nvidia.com/compute/cuda/12.2.2/local_installers/cuda-repo-ubuntu2004-12-2-local_12.2.2-535.104.05-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-12-2-local_12.2.2-535.104.05-1_amd64.deb

### Add keyring
sudo cp /var/cuda-repo-ubuntu2004-12-2-local/cuda-*-keyring.gpg /usr/share/keyrings/

### Update and install
sudo apt-get update
sudo apt-get -y install cuda
```

## Step 4: Configure Environment Variables

Set up CUDA environment variables for runtime and compilation.

Edit your shell config (~/.bashrc, ~/.zshrc, etc.):

```
export PATH=/usr/local/cuda-12.2/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.2/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda-12.2
```

Apply the changes:

`source ~/.bashrc`
