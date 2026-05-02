#!/bin/bash
sudo dnf install rocm ollama
sudo usermod -a -G render,video $USER

# create start script
mkdir -p ~/.local/bin
cat << 'EOF' > ~/.local/bin/start-ollama.sh
#!/bin/bash
export HSA_OVERRIDE_GFX_VERSION=11.0.2

# Function to shut down Ollama on exit
cleanup() {
    pkill ollama
    exit
}
trap cleanup SIGINT SIGTERM

while true; do
    # Check if Neovim (nvim) is running
    if pgrep -x "nvim" > /dev/null; then
        # If Neovim is running but Ollama isn't, start Ollama
        if ! pgrep -x "ollama" > /dev/null; then
            /usr/bin/ollama serve &
            sleep 5
            # Prime the 7B model
            curl http://localhost:11434/api/generate -d '{"model": "qwen2.5-coder:7b", "keep_alive": -1}'
        fi
    else
        # If Neovim is NOT running but Ollama IS, kill Ollama to save VRAM/Power
        if pgrep -x "ollama" > /dev/null; then
            pkill ollama
        fi
    fi
    # Wait 10 seconds before checking again to save CPU
    sleep 10
done
EOF
chmod +x ~/.local/bin/start-ollama.sh

# autostart is handled by hyprland
