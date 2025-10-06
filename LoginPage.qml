import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    width: 480
    height: 640
    color: "#ffffff"

    property int currentPage: 0
    //property string userName: usernameField.text
    signal loginSuccess()
    signal registerSuccess()

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: /*"#2980b9"*/ "#2c3e50" }
            GradientStop { position: 1.0; color: "#6dd5fa" }
        }
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
        width: 340
        height: loader.item ? loader.item.height + 60 : 400
        radius: 16
        // color: "#119f8f"
        color: "#ffffff"
        anchors.centerIn: parent

        Behavior on height {
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }

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
            width: loader.formWidth
            height: 380

            Rectangle {
                width: 70
                height: 70
                radius: 35
                color: "#ecf0f1"
                Layout.alignment: Qt.AlignHCenter

                Image {
                    source: "/res/usericon"
                    anchors.fill: parent
                    anchors.margins: 10
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

            TextField {
                id: usernameField
                placeholderText: "👤 Username"
                Layout.fillWidth: true
                font.pixelSize: 16
                background: Rectangle { color: "#ecf0f1"; radius: 8 }
                padding: 10
            }

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
                height: 40
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

            // TextField {
            //     id: passwordField
            //     placeholderText: "🔑 Password"
            //     echoMode: TextInput.Password
            //     Layout.fillWidth: true
            //     font.pixelSize: 16
            //     background: Rectangle { color: "#ecf0f1"; radius: 8 }
            //     padding: 10
            // }

            Button {
                id: loginButton
                text: "Log In"
                Layout.fillWidth: true
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

                    // var xhr = new XMLHttpRequest()
                    // // xhr.open("POST", "http://192.168.1.33:8000/login")
                    // xhr.open("POST", "https://140c7f5227dd.ngrok-free.app/login")
                    // xhr.setRequestHeader("Content-Type", "application/json")
                    // xhr.onreadystatechange = function() {
                    //     if (xhr.readyState === XMLHttpRequest.DONE) {
                    //         console.log("Login Response:", xhr.responseText)

                    //         if (xhr.status === 200) {
                    //             try {
                    //                 var response = JSON.parse(xhr.responseText)
                    //                 if (response.access_token) {
                    //                     loginSuccess()
                    //                     console.log("Login successful. Token:", response.access_token)
                    //                 } else {
                    //                     console.log("Login failed:", xhr.responseText)
                    //                     errorDialog.open()
                    //                 }
                    //             } catch (e) {
                    //                 console.log("Failed to parse JSON response")
                    //             }
                    //         } else {
                    //             console.log("HTTP error: " + xhr.status)
                    //             try {
                    //                 var errResponse = JSON.parse(xhr.responseText)
                    //                 console.log("Error message:", errResponse.detail || "Unknown error")
                    //             } catch (e) {
                    //                 console.log("Could not parse error message")
                    //             }
                    //             errorDialog.open()
                    //         }
                    //     }
                    // }

                    // var payload = {
                    //     username: usernameField.text,
                    //     email: emailField.text,
                    //     password: passwordField.text
                    // }

                    // xhr.send(JSON.stringify(payload))

                    if(usernameField.text === "" && passwordField.text === "")
                    {
                        mainWindow.loggedInUser = usernameField.text
                        loginSuccess()
                    }
                    else
                    {
                        errorDialog.open()
                    }
                }
            }

            Text {
                text: "No account? <u>Register</u>"
                color: "blue"
                textFormat: Text.RichText
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
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
            width: loader.formWidth
            height: 460

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
                height: 40
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


            // TextField {
            //     id: regPassword
            //     placeholderText: "🔑 Password"
            //     echoMode: TextInput.Password
            //     Layout.fillWidth: true
            //     font.pixelSize: 16
            //     background: Rectangle { color: "#ecf0f1"; radius: 8 }
            //     padding: 10
            // }

            Rectangle {
                Layout.fillWidth: true
                height: 40
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
        id: errorDialog
        title: "Error"
        modal: true
        standardButtons: Dialog.Ok
        onAccepted: errorDialog.close()

        onVisibleChanged: {
            if (visible) {
                x = (parent.width - width) / 2
                y = (parent.height - height) / 2
            }
        }

        ColumnLayout {
            anchors.fill: parent
            Label {
                id: errorDialogText
                text: "Invalid username or password"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }

}
