
// dashboard-data-svc.js
var fs = require('fs');

function getDatafromFile(fileName) {
    var raw =  fs.readFileSync(fileName, { "encoding": 'utf8', "flag": 'rs'});
    // remove trailing commas
    var regex = /\,(?!\s*?[\{\[\"\'\w])/g;
    raw = raw.replace(regex, '');
    return JSON.parse(raw);
}

function getDateFromMsg(msg) {
    var matches = msg.match(/audit\((\d{2}\/\d{2}\/\d{4}) (\d{2}:\d{2}:\d{2})/);
    var date = new Date(matches[1]+" "+matches[2]);
    return date.toLocaleString();
}


var dashes = [
    {
        label: 'loginSuccess',
        title: 'Successful logins',
        jsonFile: 'login-success.json',
        data: [],
        postProcess: function () { 
            for (var index = 0; index < this.data.length; index++) {
                this.data[index].date = getDateFromMsg(this.data[index].msg);
            }
        }
    },
    {
        label: 'loginUnsuccess',
        title: 'Unsuccessful logins',
        jsonFile: 'login-unsuccess.json',
        data: [],
        postProcess: function () { 
            for (var index = 0; index < this.data.length; index++) {
                this.data[index].date = getDateFromMsg(this.data[index].msg);
            }
        }
    },
    {
        label: 'userMod',
        title: 'User/Group/Role modification',
        jsonFile: 'user-mod.json',
        data: [],
        postProcess: function () { 
            for (var index = 0; index < this.data.length; index++) {
                this.data[index].date = getDateFromMsg(this.data[index].msg);
            }
        }
    },
    {
        label: 'privEsc',
        title: 'Process ID change (su / sudo / etc/sudoers)',
        jsonFile: 'priv-esc.json',
        data: [],
        postProcess: function () { 
            for (var index = 0; index < this.data.length; index++) {
                this.data[index].date = getDateFromMsg(this.data[index].msg);
            }
        }
    },
    {
        label: 'suspActivity',
        title: 'Suspicious activity',
        jsonFile: 'susp-activity.json',
        data: [],
        postProcess: function () { 
            for (var index = 0; index < this.data.length; index++) {
                this.data[index].date = getDateFromMsg(this.data[index].msg);
            }
        }
    }
];

module.exports = function () {
    var renderData = {};    // all dashboard data 
                            // is collected in keys that the template will
    dashes.forEach(dash => {
        dash.data = getDatafromFile('log/'+dash.jsonFile);
        dash.postProcess();
        renderData[dash.label] = dash;
    });

    return renderData;
}
