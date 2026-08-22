import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import QtQuick.LocalStorage 2.0

import QGroundControl                       1.0
import QGroundControl.ScreenTools 1.0

Rectangle {

    property int currentPage: 0
    signal loginSuccess()
    signal registerSuccess()

    function _checkLicense(enteredLicense) {
        var db = LocalStorage.openDatabaseSync("FWDGCS_LicenseDB", "1.0", "License Database", 100000)
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS license(key TEXT PRIMARY KEY, value TEXT)')
        })
        var stored = ""
        db.transaction(function(tx) {
            var rs = tx.executeSql('SELECT value FROM license WHERE key = "license_key"')
            if (rs.rows.length > 0) {
                stored = rs.rows.item(0).value
            }
        })
        if (stored === "") {
            db.transaction(function(tx) {
                tx.executeSql('INSERT INTO license(key, value) VALUES("license_key", ?)', [enteredLicense])
            })
            console.log("License saved for first time:", enteredLicense)
            return true
        }
        return stored === enteredLicense
    }


    anchors.fill: parent
    // gradient: Gradient {
    //     GradientStop { position: 0.0; color: /*"#2980b9"*/ "#2c3e50" }
    //     GradientStop { position: 1.0; color: "#6dd5fa" }
    // }

    // gradient: Gradient {
    //     GradientStop { position: 0.0; color: "#8B0000" }   // dark red
    //     GradientStop { position: 1.0; color: "#FF6347" }   // tomato red
    // }

    // gradient: Gradient {
    //     GradientStop { position: 0.0; color: "#DC143C" }   // crimson
    //     GradientStop { position: 1.0; color: "#FF7F7F" }   // light pinkish red
    // }

    // gradient: Gradient {
    //     GradientStop { position: 0.0; color: "#2c0505" }   // dark maroon
    //     GradientStop { position: 1.0; color: "#ff4b2b" }   // bright red-orange
    // }

    // gradient: Gradient {
    //     GradientStop { position: 0.0; color: "#8b0000" }   // dark red
    //     GradientStop { position: 0.4; color: "#dc143c" }   // crimson
    //     GradientStop { position: 0.8; color: "#ff4040" }   // light red highlight
    //     GradientStop { position: 1.0; color: "#8b0000" }   // back to dark
    // }

    // gradient: Gradient {
    //     GradientStop { position: 0.0; color: "#3b0a0a" }  // dark maroon
    //     GradientStop { position: 0.5; color: "#800000" }  // deep red
    //     GradientStop { position: 1.0; color: "#b22222" }  // firebrick red
    // }

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#2b0000" }   // very dark burgundy
        GradientStop { position: 0.5; color: "#800020" }   // burgundy
        GradientStop { position: 1.0; color: "#c72c41" }   // rose red
    }


    DropShadow {
        anchors.fill: loginCard
        horizontalOffset: 0
        verticalOffset: 4
        radius: 16
        samples: 25
        color: "#000066"
        source: loginCard
    }

    Rectangle {
        id: loginCard
        // width: ScreenTools.defaultFontPixelWidth * 30
        // width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 20
        //                             : ScreenTools.defaultFontPixelWidth * 55

        // height: ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 10
        //                              : ScreenTools.defaultFontPixelHeight * 25

        // width: Screen.width * (ScreenTools.isMobile ? 0.8 : 0.6)
        // height: Screen.height * (ScreenTools.isMobile ? 0.5 : 0.6)

        //height: loader.item ? loader.item.height + 60 : 400
        width: parent.width * (ScreenTools.isMobile ? 0.2 : 0.2)
        height: parent.height * (ScreenTools.isMobile ? 0.5 : 0.45)

        radius: 16
        // color: "#119f8f"
        color: "#ffffff"
        anchors.centerIn: parent

        // Behavior on height {
        //     NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        // }

        Loader {
            id: loader
            anchors.fill: parent
            anchors.margins: 30
            active: true
            sourceComponent: currentPage === 0 ? loginPage : registerPage
            property int formWidth: width
        }
    }

    Component {
        id: loginPage
        ColumnLayout {
            spacing: 20
            // width: loader.formWidth
            // height: loginPage.height

            Rectangle {
                width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 5
                                            : ScreenTools.defaultFontPixelWidth * 10
                height: ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 2
                                             : ScreenTools.defaultFontPixelHeight * 3
                radius: 35
                color: "#ecf0f1"
                Layout.alignment: Qt.AlignHCenter

                Image {
                    source: "/res/usericon"
                    anchors.centerIn: parent
                    width: parent.width - 20
                            height: parent.height - 20
                    fillMode: Image.PreserveAspectFit
                }
            }

            Label {
                text: "FWDGCS"
                font.pixelSize: 32
                font.bold: true
                color: "#8c3850"
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            // TextField {
            //     id: usernameField
            //     placeholderText: "👤 Username"
            //     Layout.fillWidth: true
            //     font.pixelSize: 16
            //     background: Rectangle { color: "#ecf0f1"; radius: 8 }
            //     padding: 10
            // }

            TextField {
                id: emailField
                placeholderText: "📧 Email"
                Layout.fillWidth: true
                font.pixelSize: 16
                background: Rectangle { color: "#ecf0f1"; radius: 8 }
                padding: 10
            }

            Rectangle {
                Layout.fillWidth: true
                height: emailField.height
                color: "#ecf0f1"
                radius: 8

                TextField {
                    id: passwordField
                    anchors.fill: parent
                    anchors.rightMargin: 40
                    placeholderText: "🔑 Password"
                    echoMode: TextInput.Password
                    font.pixelSize: 16
                    background: null
                    padding: 10
                }

                Image {
                    id: eyeIcon_login
                    source: passwordField.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            passwordField.echoMode =
                                passwordField.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password
                            eyeIcon_login.source =
                                passwordField.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
                        }
                    }
                }
            }

            // Rectangle {
            //     Layout.fillWidth: true
            //     height: emailField.height
            //     color: "#ecf0f1"
            //     radius: 8

            //     TextField {
            //         id: licenseField
            //         anchors.fill: parent
            //         anchors.rightMargin: 40
            //         placeholderText: "🔑 License"
            //         echoMode: TextInput.Password
            //         font.pixelSize: 16
            //         background: null
            //         padding: 10
            //     }

            //     Image {
            //         id: eyeIcon_license
            //         source: licenseField.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
            //         width: 24
            //         height: 24
            //         anchors.right: parent.right
            //         anchors.verticalCenter: parent.verticalCenter
            //         anchors.margins: 8
            //         fillMode: Image.PreserveAspectFit
            //         MouseArea {
            //             anchors.fill: parent
            //             onClicked: {
            //                 licenseField.echoMode =
            //                     licenseField.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password
            //                 eyeIcon_license.source =
            //                     licenseField.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
            //             }
            //         }
            //     }
            // }

            Button {
                id: loginButton
                text: "Log In"
                Layout.alignment: Qt.AlignHCenter
                //Layout.fillWidth: true
                font.pixelSize: 16

                background: Rectangle { implicitHeight: 40; radius: 8; color: "#3498db" }
                contentItem: Text {
                    text: loginButton.text
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    // if (licenseField.text === "") {
                    //     licenseErrorText.text = "License field cannot be empty"
                    //     licenseErrorDialog.open()
                    //     return
                    // }

                    // if (_checkLicense(licenseField.text)) {
                        loginSuccess()
                    // } else {
                    //     licenseErrorText.text = "Invalid license key"
                    //     licenseErrorDialog.open()
                    // }
                }
            }

            Label {
                text: "No account? <u>Register</u>"
                color: "blue"
                //textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: ScreenTools.isMobile ? 20 : 12
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentPage = 1
                }
            }
        }
    }

    Component {
        id: registerPage
        ColumnLayout {
            spacing: 20

            Label {
                text: "Register"
                font.pixelSize: 28
                font.bold: true
                color: "#8c3850"
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: regUsername
                placeholderText: "👤 Username"
                Layout.fillWidth: true
                font.pixelSize: 16
                background: Rectangle { color: "#ecf0f1"; radius: 8 }
                padding: 10
            }

            TextField {
                id: regEmail
                placeholderText: "📧 Email"
                Layout.fillWidth: true
                font.pixelSize: 16
                background: Rectangle { color: "#ecf0f1"; radius: 8 }
                padding: 10
            }

            Rectangle {
                Layout.fillWidth: true
                height: regPassword.height
                color: "#ecf0f1"
                radius: 8

                TextField {
                    id: regPassword
                    anchors.fill: parent
                    anchors.rightMargin: 40
                    placeholderText: "🔑 Password"
                    echoMode: TextInput.Password
                    font.pixelSize: 16
                    background: null
                    padding: 10
                }

                Image {
                    id: eyeIcon_regPassword
                    source: regPassword.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            regPassword.echoMode =
                                regPassword.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password
                            eyeIcon_regPassword.source =
                                regPassword.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: regConfirmPassword.height
                color: "#ecf0f1"
                radius: 8

                TextField {
                    id: regConfirmPassword
                    anchors.fill: parent
                    anchors.rightMargin: 40
                    placeholderText: "🔑 Password"
                    echoMode: TextInput.Password
                    font.pixelSize: 16
                    background: null
                    padding: 10
                }

                Image {
                    id: eyeIcon_regConfirmPassword
                    source: regConfirmPassword.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
                    width: 24
                    height: 24
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 8
                    fillMode: Image.PreserveAspectFit
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            regConfirmPassword.echoMode =
                                regConfirmPassword.echoMode === TextInput.Password ? TextInput.Normal : TextInput.Password
                            eyeIcon_regConfirmPassword.source =
                                regConfirmPassword.echoMode === TextInput.Password ? "/res/eye.png" : "/res/eye_off.png"
                        }
                    }
                }
            }

            Button {
                id: registerButton
                text: "Register"
                Layout.fillWidth: true
                font.pixelSize: 16
                background: Rectangle { implicitHeight: 40; radius: 8; color: "#27ae60" }
                contentItem: Text {
                    text: registerButton.text
                    anchors.centerIn: parent
                    color: "white"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    var userName = regUsername.text
                    var email = regEmail.text
                    var password = regPassword.text
                    var conPassowrd = regConfirmPassword.text

                    if (regPassword.text !== regConfirmPassword.text) {
                        errorDialogText.text = "Passwords do not match"
                        errorDialog.open()
                        return
                    }

                    var xhr = new XMLHttpRequest()
                    //xhr.open("POST", "https://b27372567217.ngrok-free.app/register")
                    xhr.open("POST", "https://140c7f5227dd.ngrok-free.app/register")
                    xhr.setRequestHeader("Content-Type", "application/json")
                    xhr.onreadystatechange = function() {
                        if(xhr.readyState === XMLHttpRequest.DONE) {
                            if(xhr.status === 200) {
                                console.log("Registration Successful: ", xhr.responseText)
                                currentPage = 0
                            } else {
                                console.log("Registration failed: ", xhr.responseText)
                            }
                        }
                    }

                    var data = {
                        username: userName,
                        email: email,
                        password: password
                    }

                    xhr.send(JSON.stringify(data))

                    // } else {
                    //     registerSuccess()
                    //     currentPage = 0
                    // }
                }
            }

            Text {
                text: "<u>Back to Login</u>"
                color: "blue"
                font.pixelSize: ScreenTools.isMobile ? 20 : 12
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: currentPage = 0
                }
            }
        }
    }

    Dialog {
        id: licenseErrorDialog
        title: "License Error"
        standardButtons: Dialog.Ok
        anchors.centerIn: parent
        modal: true

        Label {
            id: licenseErrorText
            color: "#cc0000"
            font.pixelSize: 14
        }
    }
}
