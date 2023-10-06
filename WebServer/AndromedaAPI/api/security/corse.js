const cors = require('cors');
const allowedOrigins = [`https://localhost:${process.env.PORT}`];
const log = require("../config/log");

const corseOptions = {
    origin: function(origin, callback) {
        if (!origin) {
            log.info("Request without origin header.")
            //return callback(new Error('No Origin header present'), false); //Anfragen ohne Origin header nicht erlauben
            return callback(null, false);  // Für Postman und Anfragen ohne Ursprung
        }
        
        if (allowedOrigins.indexOf(origin) === -1) {
            const msg = `The CORS policy for this site does not allow access from the specified origin ${origin}.`;
            log.crit(msg);
            return callback(new Error(msg), false);
        }
        return callback(null, true);
} }

module.exports = cors(corseOptions);