"use strict";
/**
 * Module dependencies.
 */
const cors = require('cors');

/**
 * Root routes.
 */
module.exports.app = function (app, passport) {
    /** Include before other routes. */
    app.options('*', cors());

    /** Translator endpoints. */
    app.use('/translator/', require('./translator/index')(passport));
};
