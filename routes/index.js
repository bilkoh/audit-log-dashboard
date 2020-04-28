#!/routes/index.js
var express = require('express');
var router = express.Router();
var getDashboardData = require('../dashboard-data-svc.js');

router.get('/', (req, res, next) => {
    res.render('index', getDashboardData());
});

module.exports = router;
