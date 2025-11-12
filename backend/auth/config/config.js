import generateLocalToken from "../utils/token.js";

const config = {
    PORT: process.env.PORT ? process.env.PORT : 8080,
    JWT_SECRET: process.env.JWT_SECRET ? process.env.JWT_SECRET : generateLocalToken(),
    JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN ? process.env.JWT_EXPIRES_IN : '7d'
}


export default config