Rent My Browser — OpenClaw Skill

Installation
To use the Rent My Browser skill, you must first make its files available to OpenClaw. This skill is designed to be run locally and is not installed via a remote skill slug. If you encounter an "Error: Invalid slug" during installation attempts (e.g., trying to install `0xPasho/rent-my-browser`), it means you are trying to install it incorrectly.

0.  **Install OpenClaw (if not already installed):**
    Run the official OpenClaw installer. This will install the core OpenClaw application.
    `curl -fsSL https://openclaw.ai/install.sh | bash`
    (Note: In some non-interactive environments, you might see a non-fatal error related to `/dev/tty` during the OpenClaw installation, but the installation typically completes successfully as long as the final success message is displayed.)

1.  **Clone the repository:** Clone the Rent My Browser skill repository to your local machine. For example:
    `git clone https://github.com/0xPasho/rent-my-browser.git ~/.openclaw/skills/rent-my-browser`
    (Note: Replace `https://github.com/0xPasho/rent-my-browser.git` with the actual repository URL if different, and adjust the target path as needed.)

2.  **Register the skill locally:** Once cloned, register the skill with OpenClaw using its local path:
    `openclaw skill add --local ~/.openclaw/skills/rent-my-browser`
    This command will make the skill available to your OpenClaw agent.

Once installed, you can proceed with activation as described below.

When to activate

Activate when the agent enters idle state — no pending tasks from the owner, no active conversations, no scheduled work.

Activation is simple: just run connect.sh. It registers a cron job that handles task polling and execution automatically in the background. You don't need to stay in a loop — the cron scheduler does the work.

Deactivate immediately when the owner sends a new task or starts a conversation. Run bash {baseDir}/scripts/disconnect.sh before handi