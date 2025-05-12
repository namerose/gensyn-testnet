#!/bin/bash

BOLD="\e[1m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
NC="\e[0m"

SWARM_DIR="$HOME/rl-swarm"
TEMP_DATA_PATH="$SWARM_DIR/modal-login/temp-data"
HOME_DIR="$HOME"

cd $HOME

# Function to update the repository without losing user data
update_repo() {
    echo -e "${BOLD}${YELLOW}[✓] Backing up user data...${NC}"
    
    # Create temp directory if it doesn't exist
    mkdir -p "$HOME_DIR/temp_gensyn_backup"
    
    # Backup important files if they exist
    [ -f "$SWARM_DIR/swarm.pem" ] && cp "$SWARM_DIR/swarm.pem" "$HOME_DIR/temp_gensyn_backup/"
    [ -f "$TEMP_DATA_PATH/userData.json" ] && cp "$TEMP_DATA_PATH/userData.json" "$HOME_DIR/temp_gensyn_backup/"
    [ -f "$TEMP_DATA_PATH/userApiKey.json" ] && cp "$TEMP_DATA_PATH/userApiKey.json" "$HOME_DIR/temp_gensyn_backup/"
    
    echo -e "${BOLD}${YELLOW}[✓] Updating repository...${NC}"
    
    # Check if repository exists and update it
    if [ -d "$SWARM_DIR" ]; then
        cd "$SWARM_DIR"
        
        # Reset any changes and pull latest code
        git reset --hard > /dev/null 2>&1
        git clean -fd > /dev/null 2>&1
        git pull origin main > /dev/null 2>&1
        
        # If pull failed, clone fresh
        if [ $? -ne 0 ]; then
            echo -e "${BOLD}${YELLOW}[✓] Update failed, cloning fresh repository...${NC}"
            cd "$HOME_DIR"
            rm -rf "$SWARM_DIR"
            git clone https://github.com/zunxbt/rl-swarm.git > /dev/null 2>&1
        fi
    else
        # Clone repository if it doesn't exist
        cd "$HOME_DIR"
        git clone https://github.com/zunxbt/rl-swarm.git > /dev/null 2>&1
    fi
    
    # Restore user data
    echo -e "${BOLD}${YELLOW}[✓] Restoring user data...${NC}"
    mkdir -p "$TEMP_DATA_PATH"
    [ -f "$HOME_DIR/temp_gensyn_backup/swarm.pem" ] && cp "$HOME_DIR/temp_gensyn_backup/swarm.pem" "$SWARM_DIR/"
    [ -f "$HOME_DIR/temp_gensyn_backup/userData.json" ] && cp "$HOME_DIR/temp_gensyn_backup/userData.json" "$TEMP_DATA_PATH/"
    [ -f "$HOME_DIR/temp_gensyn_backup/userApiKey.json" ] && cp "$HOME_DIR/temp_gensyn_backup/userApiKey.json" "$TEMP_DATA_PATH/"
    
    # Clean up temp directory
    rm -rf "$HOME_DIR/temp_gensyn_backup"
}

if [ -f "$SWARM_DIR/swarm.pem" ]; then
    echo -e "${BOLD}${YELLOW}You already have an existing ${GREEN}swarm.pem${YELLOW} file.${NC}\n"
    echo -e "${BOLD}${YELLOW}Do you want to:${NC}"
    echo -e "${BOLD}${GREEN}1) Just restart with existing files (quickest, use after Ctrl+C)${NC}"
    echo -e "${BOLD}2) Use existing swarm.pem and update repository${NC}"
    echo -e "${BOLD}${RED}3) Delete everything and start fresh${NC}"

    while true; do
        read -p $'\e[1mEnter your choice (1, 2, or 3): \e[0m' choice
        if [ "$choice" == "1" ]; then
            echo -e "\n${BOLD}${GREEN}[✓] Restarting with existing files...${NC}"
            # Do nothing, just proceed with existing files
            break
        elif [ "$choice" == "2" ]; then
            echo -e "\n${BOLD}${YELLOW}[✓] Using existing credentials and updating repository...${NC}"
            update_repo
            break
        elif [ "$choice" == "3" ]; then
            echo -e "${BOLD}${YELLOW}[✓] Removing existing folder and starting fresh...${NC}"
            rm -rf "$SWARM_DIR"
            cd $HOME && git clone https://github.com/zunxbt/rl-swarm.git > /dev/null 2>&1
            break
        else
            echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1, 2, or 3.${NC}"
        fi
    done
else
    echo -e "${BOLD}${YELLOW}[✓] No existing swarm.pem found.${NC}\n"
    
    if [ -d "$SWARM_DIR" ]; then
        echo -e "${BOLD}${YELLOW}Repository exists but no swarm.pem found.${NC}"
        echo -e "${BOLD}${YELLOW}Do you want to:${NC}"
        echo -e "${BOLD}1) Use existing repository without changes${NC}"
        echo -e "${BOLD}2) Update existing repository${NC}"
        echo -e "${BOLD}${RED}3) Delete and clone fresh${NC}"
        
        while true; do
            read -p $'\e[1mEnter your choice (1, 2, or 3): \e[0m' choice
            if [ "$choice" == "1" ]; then
                echo -e "\n${BOLD}${GREEN}[✓] Using existing repository without changes...${NC}"
                # Do nothing, just proceed with existing repository
                break
            elif [ "$choice" == "2" ]; then
                echo -e "\n${BOLD}${YELLOW}[✓] Updating existing repository...${NC}"
                update_repo
                break
            elif [ "$choice" == "3" ]; then
                echo -e "${BOLD}${YELLOW}[✓] Removing existing folder and starting fresh...${NC}"
                rm -rf "$SWARM_DIR"
                cd $HOME && git clone https://github.com/zunxbt/rl-swarm.git > /dev/null 2>&1
                break
            else
                echo -e "\n${BOLD}${RED}[✗] Invalid choice. Please enter 1, 2, or 3.${NC}"
            fi
        done
    else
        echo -e "${BOLD}${YELLOW}[✓] Repository not found. Cloning...${NC}"
        cd $HOME && git clone https://github.com/zunxbt/rl-swarm.git > /dev/null 2>&1
    fi
fi

cd rl-swarm || { echo -e "${BOLD}${RED}[✗] Failed to enter rl-swarm directory. Exiting.${NC}"; exit 1; }

echo -e "${BOLD}${YELLOW}[✓] Running rl-swarm...${NC}"
./run_rl_swarm.sh
