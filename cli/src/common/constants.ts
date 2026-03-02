import os from "os";
import path from "path"

export const STATE_DIR = path.join(os.homedir(), ".local/state/quickshell/user")
export const CONFIG_FILE = path.join(os.homedir(), ".config/shell/config.json")
export const ALLOWED_WALLPAPER_EXTENSIONS = ['.jpg', '.jpeg', '.png']
