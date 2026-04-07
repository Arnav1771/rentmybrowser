#!/usr/bin/env bash
set -euo pipefail

# RentMyBrowser GitHub Actions Setup for macOS/Linux
# This script guides you through setting up your earning node

COLOR_INFO='\033[0;36m'
COLOR_SUCCESS='\033[0;32m'
COLOR_WARNING='\033[0;33m'
COLOR_ERROR='\033[0;31m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_header() {
    clear
    echo -e "${COLOR_INFO}════════════════════════════════════════════════════════════${NC}"
    echo -e "${COLOR_INFO}  🌐 RentMyBrowser + GitHub Actions Setup${NC}"
    echo -e "${COLOR_INFO}  Earn money from your idle browser${NC}"
    echo -e "${COLOR_INFO}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

show_menu() {
    echo -e "${COLOR_INFO}Choose an option:${NC}"
    echo ""
    echo "  [1] 📚 Show Setup Guide (read SETUP_GUIDE.md)"
    echo "  [2] 🔑 Get Gemini API Key (opens browser)"
    echo "  [3] ✅ Check Prerequisites (gh, git, node)"
    echo "  [4] 📦 Create GitHub Repository"
    echo "  [5] 🔐 Add GEMINI_API_KEY Secret"
    echo "  [6] 🚀 Trigger Workflow (start earning!)"
    echo "  [7] 📊 Check Workflow Status"
    echo "  [8] 📖 View Logs"
    echo "  [9] ⚙️  Set Repository URL (if needed)"
    echo "  [0] 🚪 Exit"
    echo ""
}

check_prerequisites() {
    print_header
    echo -e "${COLOR_INFO}Checking prerequisites...${NC}"
    echo ""
    
    local missing=()
    
    # Check gh
    if command -v gh &> /dev/null; then
        local gh_version=$(gh --version)
        echo -e "${COLOR_SUCCESS}✅ GitHub CLI:${NC} $gh_version"
    else
        echo -e "${COLOR_ERROR}❌ GitHub CLI not found${NC}"
        missing+=("GitHub CLI (gh)")
    fi
    
    # Check git
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        echo -e "${COLOR_SUCCESS}✅ Git:${NC} $git_version"
    else
        echo -e "${COLOR_ERROR}❌ Git not found${NC}"
        missing+=("Git")
    fi
    
    # Check GitHub auth
    if gh auth status &> /dev/null; then
        echo -e "${COLOR_SUCCESS}✅ GitHub Authentication:${NC} Logged in"
    else
        echo -e "${COLOR_WARNING}⚠️  GitHub Authentication:${NC} Not authenticated"
        missing+=("GitHub CLI authentication")
    fi
    
    # Check Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        echo -e "${COLOR_SUCCESS}✅ Node.js:${NC} $node_version"
    else
        echo -e "${COLOR_WARNING}⚠️  Node.js:${NC} Not found (optional, but recommended)"
    fi
    
    echo ""
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${COLOR_ERROR}Missing prerequisites:${NC}"
        for item in "${missing[@]}"; do
            echo -e "  ${COLOR_ERROR}•${NC} $item"
        done
        echo ""
        echo -e "${COLOR_INFO}To install:${NC}"
        echo -e "  ${COLOR_INFO}•${NC} GitHub CLI: https://cli.github.com/"
        echo -e "  ${COLOR_INFO}•${NC} Git: https://git-scm.com/"
        echo ""
    else
        echo -e "${COLOR_SUCCESS}All prerequisites met! ✅${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

get_gemini_key() {
    print_header
    echo -e "${COLOR_INFO}Getting your Gemini API Key...${NC}"
    echo ""
    echo -e "${COLOR_WARNING}A browser will open to aistudio.google.com${NC}"
    echo ""
    echo -e "${COLOR_INFO}Steps:${NC}"
    echo "  1. Click 'Create API Key'"
    echo "  2. Select 'Create API key in new project'"
    echo "  3. Copy the API key"
    echo "  4. Save it somewhere safe (you'll need it next)"
    echo ""
    
    read -p "Press Enter when you're ready (will open browser)"
    
    # macOS or Linux
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "https://aistudio.google.com/app/apikeys"
    else
        xdg-open "https://aistudio.google.com/app/apikeys" 2>/dev/null || \
        echo -e "${COLOR_WARNING}Please visit: https://aistudio.google.com/app/apikeys${NC}"
    fi
    
    echo ""
    echo -e "${COLOR_SUCCESS}✅ Browser opened. Copy your API key when ready.${NC}"
    echo ""
    read -p "Press Enter after copying your API key"
}

show_setup_guide() {
    print_header
    echo -e "${COLOR_INFO}Opening SETUP_GUIDE.md...${NC}"
    echo ""
    
    local guide_path="$SCRIPT_DIR/SETUP_GUIDE.md"
    if [ -f "$guide_path" ]; then
        less -R "$guide_path"
    else
        echo -e "${COLOR_ERROR}❌ SETUP_GUIDE.md not found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

create_repository() {
    print_header
    echo -e "${COLOR_INFO}Creating GitHub Repository...${NC}"
    echo ""
    
    local user
    if ! user=$(gh api user -q '.login' 2>/dev/null); then
        echo -e "${COLOR_ERROR}❌ Not authenticated with GitHub CLI${NC}"
        echo -e "${COLOR_WARNING}Run: gh auth login${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo -e "${COLOR_INFO}Logged in as: ${COLOR_SUCCESS}$user${NC}"
    echo ""
    echo -e "${COLOR_INFO}Repository will be:${NC}"
    echo -e "  https://github.com/$user/rentmybrowser-node"
    echo ""
    read -p "Create private repository? (y/n): " confirm
    
    if [ "$confirm" != "y" ] && [ "$confirm" != "yes" ]; then
        echo -e "${COLOR_WARNING}Cancelled.${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo ""
    echo -e "${COLOR_INFO}Creating repository...${NC}"
    
    if [ ! -d ".git" ]; then
        git init
        git add .
        git commit -m "Initial commit: RentMyBrowser node setup"
        git branch -M main
    fi
    
    if gh repo create rentmybrowser-node --private --source=. --remote=origin --push; then
        echo ""
        echo -e "${COLOR_SUCCESS}✅ Repository created!${NC}"
        echo -e "${COLOR_SUCCESS}   https://github.com/$user/rentmybrowser-node${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

add_secret() {
    print_header
    echo -e "${COLOR_INFO}Adding GEMINI_API_KEY Secret...${NC}"
    echo ""
    
    local repo
    if ! repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null); then
        echo -e "${COLOR_ERROR}❌ Cannot determine repository${NC}"
        echo -e "${COLOR_WARNING}Make sure you're in the rentmybrowser directory${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo -e "${COLOR_SUCCESS}Repository: $repo${NC}"
    echo ""
    
    read -s -p "Enter your Gemini API Key: " api_key
    echo ""
    
    if [ -z "$api_key" ]; then
        echo -e "${COLOR_ERROR}❌ API Key cannot be empty${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo ""
    echo -e "${COLOR_INFO}Adding secret...${NC}"
    
    if echo "$api_key" | gh secret set GEMINI_API_KEY -R "$repo"; then
        echo ""
        echo -e "${COLOR_SUCCESS}✅ Secret added successfully!${NC}"
        echo ""
        echo -e "${COLOR_INFO}Visible secrets:${NC}"
        gh secret list -R "$repo"
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

trigger_workflow() {
    print_header
    echo -e "${COLOR_INFO}Triggering Browser Node Workflow...${NC}"
    echo ""
    
    local repo
    if ! repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null); then
        echo -e "${COLOR_ERROR}❌ Cannot determine repository${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo -e "${COLOR_SUCCESS}Repository: $repo${NC}"
    echo ""
    echo -e "${COLOR_INFO}🚀 Starting workflow...${NC}"
    
    if gh workflow run browser-node.yml -R "$repo"; then
        echo ""
        echo -e "${COLOR_SUCCESS}✅ Workflow triggered!${NC}"
        echo ""
        echo -e "${COLOR_INFO}Your node will start in ~30 seconds.${NC}"
        echo -e "${COLOR_INFO}Monitor progress:${NC}"
        echo "  • GitHub: https://github.com/$repo/actions"
        echo "  • RentMyBrowser: https://rentmybrowser.dev/dashboard"
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

check_status() {
    print_header
    echo -e "${COLOR_INFO}Checking Workflow Status...${NC}"
    echo ""
    
    local repo
    if ! repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null); then
        echo -e "${COLOR_ERROR}❌ Cannot determine repository${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo -e "${COLOR_INFO}Recent workflow runs:${NC}"
    echo ""
    gh run list -R "$repo" --limit 5
    
    echo ""
    echo -e "${COLOR_INFO}Full dashboard: https://github.com/$repo/actions${NC}"
    echo ""
    read -p "Press Enter to continue"
}

view_logs() {
    print_header
    echo -e "${COLOR_INFO}Viewing Workflow Logs...${NC}"
    echo ""
    
    local repo
    if ! repo=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null); then
        echo -e "${COLOR_ERROR}❌ Cannot determine repository${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    echo -e "${COLOR_INFO}Fetching latest run...${NC}"
    echo ""
    
    local latest_run
    if latest_run=$(gh run list -R "$repo" --limit 1 --json number -q '.[0].number' 2>/dev/null); then
        echo -e "${COLOR_INFO}Latest run (#$latest_run):${NC}"
        echo ""
        gh run view "$latest_run" -R "$repo" --log
    else
        echo -e "${COLOR_ERROR}❌ No workflow runs found${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

set_repo_url() {
    print_header
    echo -e "${COLOR_INFO}Setting Repository URL...${NC}"
    echo ""
    
    echo -e "${COLOR_INFO}Current remote:${NC}"
    git remote -v
    
    echo ""
    read -p "Enter new repository URL (e.g., https://github.com/user/repo.git): " repo_url
    
    if [ -z "$repo_url" ]; then
        echo -e "${COLOR_ERROR}❌ URL cannot be empty${NC}"
        echo ""
        read -p "Press Enter to continue"
        return
    fi
    
    if git remote set-url origin "$repo_url"; then
        echo ""
        echo -e "${COLOR_SUCCESS}✅ Remote URL updated!${NC}"
        echo ""
        echo -e "${COLOR_INFO}Updated remote:${NC}"
        git remote -v
    fi
    
    echo ""
    read -p "Press Enter to continue"
}

# Main loop
while true; do
    print_header
    show_menu
    
    read -p "Enter choice: " choice
    
    case "$choice" in
        1) show_setup_guide ;;
        2) get_gemini_key ;;
        3) check_prerequisites ;;
        4) create_repository ;;
        5) add_secret ;;
        6) trigger_workflow ;;
        7) check_status ;;
        8) view_logs ;;
        9) set_repo_url ;;
        0)
            echo ""
            echo -e "${COLOR_SUCCESS}👋 Goodbye! Happy earning! 🚀${NC}"
            exit 0
            ;;
        *)
            echo ""
            echo -e "${COLOR_ERROR}❌ Invalid choice. Try again.${NC}"
            read -p "Press Enter to continue"
            ;;
    esac
done
