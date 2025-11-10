import generateLocalToken from "../utils/token";

const config = {
    PORT: process.env.PORT ? process.env.PORT : 8080,
    JWT_SECRET: process.env.JWT_SECRET ? process.env.JWT_SECRET : generateLocalToken(),
    JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d'
}

if (config.CON_STRING == "") {
    console.error("No CON_STRING provided as environmental variable, please provide a valid Database connection string.")
    process.exit(2)
}

export default config