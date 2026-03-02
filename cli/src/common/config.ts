import { CONFIG_FILE } from "./constants"

export async function openFile() {
    const file = await Bun.file(CONFIG_FILE).json()

    return file;
}

export async function writeFile(content: object) {
    const file = Bun.write(CONFIG_FILE, JSON.stringify(content))
}

/**
 * Define um valor de um objeto usando a notação key1.key2.key3
 * @param object 
 * @param path 
 * @param value
 * @returns
 */
function setDeep(object: Record<string, any>, path: string, value: any) {
    if (!path) return value;
    const keys = path.split(".");
    keys.reduce((curr, key, idx) => {
        if (idx === keys.length - 1) {
            curr[key] = value;
        } else if (typeof curr[key] !== "object" || curr[key] === null) {
            curr[key] = {};
        }
        return curr[key];
    }, object);
    return object;
}

/**
 * Obtém um valor de um objeto usando a notação key1.key2.key3
 * @param object 
 * @param path 
 * @returns
 */
function getDeep(object: Record<string, any>, path: string) {
    if (!path) return object;
    return path.split(".").reduce((curr, key) => {
        if (curr && typeof curr === "object") return curr[key];
        return undefined;
    }, object as any);
}

export async function setOption(path: string, value: any) {
    const file = await openFile();
    const updatedContent = setDeep(file, path, value);
    await writeFile(updatedContent)
}

export async function getOption(path: string) {
    const file = await openFile();
    return getDeep(file, path);
}