module.exports = {
    apps : [{
        name      : "CINAF-PUB-TV",
        script    : "./server.js",
        instances : "max",
        exec_mode : "cluster"
    }]
}
