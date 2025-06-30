# Zink

A powerful shell script automation tool that automatically installs and manages shell script aliases in your shell configuration file. Zink scans the `src/` directory for shell scripts and creates convenient aliases for them, making your custom scripts easily accessible from anywhere in your terminal.

## Features

- **Flexible Shell Support**: Works with any shell configuration file (`.zshrc`, `.bashrc`, `.bash_profile`, etc.)
- **Configuration Management**: Stores your shell configuration path in a `.config` file for future use
- **Automatic Installation**: Automatically installs aliases for all `.sh` files in the `src/` directory
- **Self-Managing**: Automatically updates aliases when scripts are added, modified, or removed
- **Clean Integration**: Seamlessly integrates with your existing shell configuration file
- **Silent Mode**: Supports silent installation for automated setups
- **Portable**: Works across different systems with minimal configuration
- **Environment Variables**: Sets up `ZINK_DIR` environment variable for script access

## Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd zink
   ```

2. **Run the installation script**:
   ```bash
   bash install.sh
   ```

3. **First-time setup**: The script will prompt you to enter the path to your shell configuration file:
   ```
   Enter the path to your shell configuration file: .zshrc
   ```
   
   Common configuration files:
   - `.zshrc` (Zsh)
   - `.bashrc` (Bash)
   - `.bash_profile` (Bash login shell)

4. **Reload your shell configuration**:
   ```bash
   source ~/.zshrc  # or your chosen config file
   ```

The installation script will:
- Create a `.config` file to store your shell configuration path
- Add necessary markers to your shell configuration file
- Create aliases for all scripts in the `src/` directory
- Set up automatic reinstallation on shell startup
- Export the `ZINK_DIR` environment variable

## Available Scripts

### `aliases`
Lists all available aliases and their corresponding scripts.

**Usage**:
```bash
aliases
```

**Output**:
```
3 aliases:

    aliases
    ftree
    killport
```

### `killport`
Kills all processes running on a specified port.

**Usage**:
```bash
killport <port_number>
```

**Examples**:
```bash
killport 3000    # Kill all processes on port 3000
killport 8080    # Kill all processes on port 8080
```

**Features**:
- Automatically finds and kills all processes using the specified port
- Provides detailed output of what processes are being killed
- Supports silent mode for automated scripts

### `ftree`
Displays a directory tree structure, excluding common unwanted files.

**Usage**:
```bash
ftree [directory]
```

**Examples**:
```bash
ftree              # Show tree of current directory
ftree /path/to/dir # Show tree of specified directory
```

**Features**:
- Automatically excludes common files like `.DS_Store`, `__pycache__`, `.pyc`, `.log`, etc.
- Clean, readable tree output
- Sorts files alphabetically

## How It Works

Zink modifies your shell configuration file by adding:

1. **Configuration File**: `.config` stores your shell configuration path for future installations
2. **Header Section**: Contains the script identification, environment variables, and self-installation command
3. **Alias Section**: Bounded by start and end markers, contains all the aliases
4. **Self-Installation**: Automatically reinstalls aliases on shell startup

The installation script:
- Prompts for shell configuration path on first run
- Scans the `src/` directory for `.sh` files
- Creates aliases based on the filename (without the `.sh` extension)
- Updates existing aliases if scripts are modified
- Removes aliases for deleted scripts
- Maintains the integrity of your existing shell configuration

## Adding New Scripts

To add a new script:

1. Create a new `.sh` file in the `src/` directory
2. Make it executable: `chmod +x src/your-script.sh`
3. Run the installation script: `bash install.sh`
4. The new alias will be automatically available

## Silent Installation

For automated setups or CI/CD pipelines, you can run the installation in silent mode:

```bash
bash install.sh silent
```

This will perform the installation without any output messages.

## Configuration

Zink stores your configuration in a `.config` file in the project directory:

```
BASH_PROFILE_PATH=/Users/username/.zshrc
```

This file is created automatically on first installation and used for subsequent installations.

## File Structure

```
zink/
├── install.sh          # Main installation script
├── .config             # Configuration file (created on first run)
├── README.md           # This file
└── src/                # Scripts directory
    ├── aliases.sh      # Lists all available aliases
    ├── ftree.sh        # Directory tree display
    └── killport.sh     # Port process killer
```

## Requirements

- macOS or Linux
- Bash shell (for script execution)
- Write access to your shell configuration file
- Any shell (Zsh, Bash, etc.)

## Troubleshooting

### Aliases not working after installation
1. Reload your shell configuration: `source ~/.zshrc` (or your config file)
2. Check if the installation was successful: `aliases`
3. Verify the markers are in your config file: `grep "Zink" ~/.zshrc`

### Script not found errors
1. Ensure the script file exists in the `src/` directory
2. Make sure the script is executable: `chmod +x src/script-name.sh`
3. Re-run the installation: `bash install.sh`

### Permission denied errors
1. Make sure the installation script is executable: `chmod +x install.sh`
2. Ensure you have write permissions to your shell configuration file

### Configuration issues
1. Check the `.config` file exists and contains the correct path
2. Verify the path in `.config` points to a valid shell configuration file
3. Delete `.config` and re-run installation to reconfigure

## Contributing

1. Add your new scripts to the `src/` directory
2. Make sure they are executable and have proper error handling
3. Update this README.md to document new scripts
4. Test the installation process

## License

[Add your license information here]

---

**Quick Start**

curl -L -o zink.zip https://github.com/wayfaring-stranger/zink/archive/refs/heads/main.zip;
unzip zink.zip -d zink;
rm zink.zip;
mv zink/zink-main/src/ zink/src/;
mv zink/zink-main/constants.sh zink/constants.sh;
mv zink/zink-main/utils.sh zink/utils.sh;
mv zink/zink-main/zink.sh zink/zink.sh;
mv zink/zink-main/install.sh zink/install.sh;
rm -rf zink/zink-main;
cd zink;
bash install.sh;
cd ~;

**Note**: Zink is designed to work with any shell configuration file. The installation script will prompt you to specify the correct path for your system and shell preference.
