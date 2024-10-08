import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import Game 1.0


Window {
    id: gameWindow  // Assign an ID to the main Window
    visible: true
    width: 1920
    height: 980
    title: "Flappy Ball Game"
    color: "#70c5ce"  // Background color similar to the original Flappy ball sky

    // Gravity and ball Control
    property bool isGameOver: false
    property real gravity: 0.5
    property real lift: -12
    property real ballVelocity: 0
    property int score: 0  // Property to track score

    GameController {
            id: gameController
            onGameOver: {
                console.log("game over");
                setGameOver(true);
            }
            onUpdateScore: {  // Add this to update high score dynamically when score changes
                highScoreText.text = "High Score: " + gameController.getHighScore();
                console.log("High score updated in QML: " + gameController.getHighScore());
               }
            onGameResetSignal: {
                ball.y = gameWindow.height / 2;  // Reset ball position
                        ballVelocity = 0;                // Reset velocity
                        pipeRepeater.model = 0;          // Clear all pipes
                        pipeRepeater.model = 3;          // Restart pipes
                        setGameOver(false);              // Set game state to running
                        score = 0;                       // Reset score to zero
                        scoreText.text = "Score: 0";     // Reset the score display
            }
        }

    // Function to set the game over state
       function setGameOver(state) {
           isGameOver = state;
           gameOverText.visible = state;
           restartButton.visible = state;


            highScoreText.text = "High Score: " + gameController.getHighScore();  // Update high score display
       }



    // ball element
    Rectangle {
        id: ball
        width: 40
        height: 40
        color: "yellow"
        radius: 20
        anchors.horizontalCenter: gameWindow.horizontalCenter
        x: 200
        y: gameWindow.height / 2

        Behavior on y {
                  NumberAnimation { duration: 0 }
              }
    }

    // Pipe element
    Repeater {
           id: pipeRepeater
         model: 3
        Rectangle {
            width: 50
            color: "green"
            y: Math.random() * (gameWindow.height - 300)  // Initial random position
            height: 50

            SequentialAnimation on x {
                NumberAnimation {
                    from: gameWindow.width
                    to: -width
                    duration: 4000
                       loops: Animation.Infinite

                }
            }
            // Consolidated logic for collision detection, scoring, and pipe reset
                    onXChanged: {
                        // Check for collision with the ball
                        if (!isGameOver && (ball.x + ball.width > x) &&
                            ball.x < (x + width) && (ball.y + ball.height) > y && ball.y < y + height) {
                            console.log("touched");
                            gameController.stopGame(score);
                        }

                        // Increment the score when the ball successfully passes a pipe
                        if (!isGameOver && (x + width < ball.x) && !objectPassed) {
                            score += 1;  // Increment the score
                            scoreText.text = "Score: " + score;  // Update the score display
                            objectPassed = true;  // Mark the pipe as passed to prevent duplicate scoring
                        }

                        // Reset the objectPassed flag and randomize the pipe's vertical position only when it touches the left side
                        if (x >= gameWindow.width - 10) {  // Check if the pipe has fully exited the screen on the left side
                            objectPassed = false;  // Reset the flag for the new pipe

                            // Randomize the pipe's vertical position when it reappears on the right side
                            y = Math.random() * (gameWindow.height - 300);
                            x = gameWindow.width;  // Move the pipe back to the right side of the screen
                        }
                    }


                        property bool objectPassed: false  // Tracks if the pipe has been passed
                        property bool valuePassed: false
        }
    }

    // Spawn pipes periodically
    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: {
               if (!isGameOver) {
                   ball.y += ballVelocity;
                   ballVelocity += gravity;

                   // Limit the ball's position to prevent it from going above the screen
                             if (ball.y < 0) {
                                 ball.y = 0;  // Prevent the ball from going higher than the top of the screen
                                 ballVelocity = 0;  // Reset the velocity to stop it from continuing upwards
                             }

                   // Collision detection with ground
                   if (ball.y + ball.height > gameWindow.height)
                   {
                       gameController.stopGame(score);
                   }
               }
           }
       }


    // Handle user input
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!isGameOver) {
                ballVelocity = lift;
            }
        }
    }


    Text {
          id: scoreText
          text: "Score: 0"
          font.pixelSize: 24
          color: "white"
          anchors.top: gameWindow.top
          anchors.horizontalCenter: gameWindow.horizontalCenter
          anchors.topMargin: 10
      }

      Text {
          id: highScoreText
              text: "High Score: " + gameController.getHighScore()
              font.pixelSize: 24
              color: "white"
              anchors.top: scoreText.bottom
              anchors.horizontalCenter: gameWindow.horizontalCenter
              anchors.topMargin: 10
      }



    // Display Game Over Text
    Text {
           id: gameOverText
           text: "Game Over!"
           font.pixelSize: 32
           color: "red"
           visible: false
           anchors.centerIn: parent
           anchors.verticalCenterOffset: -60  // Move the text up by 10px
       }

    // Restart Button
    Button {
        id: restartButton
        text: "Restart"
        font.pixelSize: 25
        visible: false
        anchors.centerIn: parent
        width: 100  // Optional: Set a fixed width for better alignment
        height: 50  // Optional: Set a fixed height for better alignment
        onClicked: {
            gameController.restartGame();
        }
    }

}
