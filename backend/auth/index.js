import express from 'express';
import cookieParser from 'cookie-parser';
import sequelize from './db.js';

import config from './config/config.js';
import {
    Register,
    Login,
    Logout,
    Authenticate
} from './controllers/users.controllers.js';

const app = express();
const { PORT } = config;
const ROUTE_PREFIX = '/api/v1/auth';

app.post(`${ROUTE_PREFIX}/register`, Register);
app.post(`${ROUTE_PREFIX}/login`, Login);
app.post(`${ROUTE_PREFIX}/logout`, Logout);
app.get(`${ROUTE_PREFIX}/authenticate`, Authenticate);

app.use(express.json());
app.use(cookieParser());


async function main() {
    try {
        console.log("Connecting to database...");
        await sequelize.authenticate();
        console.log("Database connection established.");
        await sequelize.sync();
        console.log("Database synchronized.");

        app.listen(PORT)
        console.log(`Server is running on port ${PORT}`);
    } catch (error) {
        console.error("Database connection failed:", error);
        process.exit(1);
    }
}

main()