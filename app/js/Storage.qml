import QtQuick 2.4
import QtQuick.LocalStorage 2.0

Item {
    property var db: null

    /**
     * Open database
     */
    function openDB() {
        if (db != null) return;
        db = LocalStorage.openDatabaseSync("Shadowsocks", "", "Database of Shadowsocks", 10000000)
        // NOTE: deal version if do some update
        console.debug("[DATABASE]:", db.version)

        if (db.version === "") {
            db.changeVersion("", "0.1", function(tx) {
                tx.executeSql("create table if not exists profile(id integer primary key autoincrement, name text, server text, remote_port integer, local_port integer, password text, method text)");

                tx.executeSql("create table if not exists config(key text, value text)");
                console.log('Database created');
            });
            // reopen database with new version number
            db = LocalStorage.openDatabaseSync("Shadowsocks", "", "Database of Shadowsocks", 10000000);
        }
    }

    function profileSave(profile) {
        openDB();
        db.transaction(function(tx) {
            console.log("--------------", profile.id)
            if (profile.id) {
                console.log("update")
                tx.executeSql(
                    "update profile set name=?, server=?, remote_port=?, local_port=?, password=?, method=? where id=?",
                    [profile.name, profile.server, profile.remote_port, profile.local_port, profile.password, profile.method, profile.id]
                )
            } else {
                console.log("insert")
                tx.executeSql(
                    "insert into profile(name, server, remote_port, local_port, password, method) values(?, ?, ?, ?, ?, ?)",
                    [profile.name, profile.server, profile.remote_port, profile.local_port, profile.password, profile.method]
                )
            }
        });
    }

    function profileDel(id) {
        openDB();
        db.transaction(function(tx) {
            console.log("--id: ", id)
            tx.executeSql(
                "delete from profile where id=?",
                [id]
            )
        });
    }

    function profileGet(name, cb) {
        openDB();
        var profile;
        db.transaction(function(tx) {
            var rs = tx.executeSql(
                "select id, name, server, remote_port, local_port, password, method from profile where name=?",
                [name]
            );
            if (rs.rows.length != 0) {
                profile = rs.rows.item(0);
            }
            cb(profile);
        });
    }

    function profileGetById(id, cb) {
        openDB();
        var profile;
        db.transaction(function(tx) {
            var rs = tx.executeSql(
                "select id, name, server, remote_port, local_port, password, method from profile where id=?",
                [id]
            );
            if (rs.rows.length != 0) {
                profile = rs.rows.item(0);
            }
            cb(profile);
        });
    }

    function profileAll(cb) {
        openDB();
        var profiles = [];
        db.transaction(function(tx) {
            var rs = tx.executeSql("select id, name, server, remote_port, local_port, password, method from profile");
            for (var i = 0; i < rs.rows.length; i++) {
                profiles.push(rs.rows.item(i))
            }
            cb(profiles)
        });
    }

    function configGet(key, cb) {
        openDB();
        db.transaction(function(tx) {
            var rs = tx.executeSql("select value from config where key=?", [key])
            if (rs.rows.length != 0) {
                cb(rs.rows.item(0).value);
            } else {
                cb(null)
            }
        })
    }

    function configSet(key, value) {
        openDB();
        db.transaction(function(tx) {
            tx.executeSql("delete from config where key=?", [key])
            tx.executeSql("insert into config values(?, ?)", [key, value])
        })
    }
}
