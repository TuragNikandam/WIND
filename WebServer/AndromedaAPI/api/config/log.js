const { createLogger, format, transports } = require('winston');


let logger = createLogger({
  level: 'info',
  levels: {
    crit: 0,
    warn: 1,
    info: 2,
    debug: 3,
  },
  format: format.combine(
    format.prettyPrint(),
    format.timestamp({
      format: 'DD-MM-YYYY hh:mm:ss A'
    }),
    format.printf(nfo => {
      return `${nfo.timestamp} - ${nfo.level}: ${nfo.message}`
    })
  ),
  transports: [
    new transports.File({ filename: 'logs/critical.log', level: 'crit' }),
    new transports.File({ filename: 'logs/warnings.log', level: 'warn' }),
    new transports.File({ filename: 'logs/info.log', level: 'info' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new transports.Console());
}

// Extend logger object to properly log 'Error' types
let origLog = logger.log;

logger.log = function (level, msg) {
  if ((level === 'crit' || msg instanceof Error) && msg instanceof Error) {
    origLog.call(logger, level, `${msg.message} - Stack: ${msg.stack}`);
  } else {
    origLog.apply(logger, arguments);
  }
};

module.exports = logger;