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
            db.changeVersion("", "1.0.0", function(tx) {
                tx.executeSql("CREATE TABLE IF NOT EXISTS profile(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, server TEXT, remote_port INTEGER, local_port INTEGER, password TEXT, method TEXT)");

                tx.executeSql("CREATE TABLE IF NOT EXISTS config(key TEXT, value TEXT)");
                console.log('Database created');
            });
            // reopen database with new version number
            db = LocalStorage.openDatabaseSync("Shadowsocks", "", "Database of Shadowsocks", 10000000);
        }

        if (db.version === "1.0.0") {
            console.debug("[DATABASE]: Upgrade 1.0.0 -> 1.0.5")
            // Add server traffic statistics
            db.changeVersion("1.0.0", "1.0.5", function(tx) {
                tx.executeSql("ALTER TABLE profile ADD sent INTEGER DEFAULT 0")
                tx.executeSql("ALTER TABLE profile ADD received INTEGER DEFAULT 0")
            })
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
                    "UPDATE profile SET name=?, server=?, remote_port=?, local_port=?, password=?, method=? where id=?",
                    [profile.name, profile.server, profile.remote_port, profile.local_port, profile.password, profile.method, profile.id]
                )
            } else {
                console.log("insert")
                tx.executeSql(
                    "INSERT INTO profile(name, server, remote_port, local_port, password, method) VALUES(?, ?, ?, ?, ?, ?)",
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
                "DELETE FROM profile WHERE id=?",
                [id]
            )
        });
    }

    function profileGet(name, cb) {
        openDB();
        var profile;
        db.transaction(function(tx) {
            var rs = tx.executeSql(
                "SELECT id, name, server, remote_port, local_port, password, method, sent, received FROM profile WHERE name=?",
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
                "SELECT id, name, server, remote_port, local_port, password, method, sent, received FROM profile WHERE id=?",
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
            var rs = tx.executeSql("SELECT id, name, server, remote_port, local_port, password, method, sent, received FROM profile");
            for (var i = 0; i < rs.rows.length; i++) {
                profiles.push(rs.rows.item(i))
            }
            cb(profiles)
        });
    }

    function configGet(key, cb) {
        openDB();
        db.transaction(function(tx) {
            var rs = tx.executeSql("SELECT value FROM config WHERE key=?", [key])
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
            tx.executeSql("DELETE FROM config WHERE key=?", [key])
            tx.executeSql("INSERT INTO config VALUES(?, ?)", [key, value])
        })
    }

    function updateProfileSent(id, sentBytes) {
        openDB();
        db.transaction(function(tx) {
            tx.executeSql("UPDATE profile SET sent=sent+? WHERE id=?", [sentBytes, id])
        })
    }

    function updateProfileReceived(id, receivedBytes) {
        openDB();
        db.transaction(function(tx) {
            tx.executeSql("UPDATE profile SET received=received+? WHERE id=?", [receivedBytes, id])
        })
    }
}
