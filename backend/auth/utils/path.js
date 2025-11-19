import path from "path"
import { fileURLToPath } from "url";

const __filename = path.join(fileURLToPath(import.meta.url), "..", "..", "index.js")
const __dirname = path.dirname(__filename)

export default {
    filename: __filename,
    dirname: __dirname
}



