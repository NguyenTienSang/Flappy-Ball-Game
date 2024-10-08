#include "gamecontroller.h"
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

GameController::GameController(QObject *parent)
    : QObject(parent), score(0)
{
      setupDatabase();
    // Debugging check to verify that the database is open
    if (db.isOpen()) {
        qDebug() << "Database is open and ready for use.";
    } else {
        qWarning() << "Database is not open immediately after setup.";
    }
}


void GameController::setupDatabase()
{
    // Specify the database path using QStandardPaths
    QString databasePath = QDir::homePath() + "/game_scores.db";

    // Debug: Log the database path
    qDebug() << "Attempting to create/open the database at path:" << databasePath;

    // Ensure the AppDataLocation directory exists
    QDir dir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "Failed to create the directory for the database at path:" << QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
            return;
        } else {
            qDebug() << "Successfully created the directory for the database.";
        }
    } else {
        qDebug() << "Directory for database already exists.";
    }

    // Check if the named connection already exists
    if (QSqlDatabase::contains("game_connection")) {
        db = QSqlDatabase::database("game_connection");
    } else {
        // Create a new connection to the SQLite database
        db = QSqlDatabase::addDatabase("QSQLITE", "game_connection");
        db.setDatabaseName(databasePath);

        // Open the database connection and check for errors
        if (!db.open()) {
            qWarning() << "Failed to open the database at path:" << databasePath << "Error:" << db.lastError().text();
            return;
        }

        // Log the successful database connection
        qDebug() << "Database successfully opened at path:" << databasePath;

        // Create the scores table if it doesn't exist
        QSqlQuery query(db);
        if (!query.exec("CREATE TABLE IF NOT EXISTS scores (id INTEGER PRIMARY KEY AUTOINCREMENT, score INTEGER)")) {
            qWarning() << "Failed to create the scores table:" << query.lastError().text();
        }
    }
}

void GameController::saveScore(int score)
{
    if (db.isOpen()) {
        QSqlQuery query(db);
        query.prepare("INSERT INTO scores (score) VALUES (:score)");
        query.bindValue(":score", score);
        if (!query.exec()) {
            qWarning() << "Failed to save score:" << query.lastError().text();
        } else {
            qDebug() << "Score saved successfully to the database! Score:" << score;
        }
    } else {
        qWarning() << "Database is not open, cannot save score.";
    }
}

int GameController::getHighScore() const
{
    int highScore = 0;
    if (db.isOpen()) {
        QSqlQuery query(db);
        query.exec("SELECT MAX(score) FROM scores");
        if (query.next()) {
            highScore = query.value(0).toInt();
            qDebug() << "High score retrieved from database: " << highScore;
        } else {
            qWarning() << "Failed to retrieve high score:" << query.lastError().text();
        }
    } else {
        qWarning() << "Database is not open, cannot retrieve high score.";
    }
    return highScore;
}


void GameController::startGame()
{
    score = 0;
    emit updateScore(score);
}

void GameController::stopGame(int scoreAchived)
{
    saveScore(scoreAchived);  // Save the current score to the database
    int newHighScore = getHighScore();  // Retrieve the latest high score from the database
    emit updateScore(newHighScore);  // Emit the signal to notify QML about the new high score
    emit gameOver();  // Notify that the game is over
}

void GameController::restartGame()
{
    gameReset();  // Call gameReset() before starting the game
    startGame();  // Start the game again
}


void GameController::gameReset()
{
    emit gameResetSignal();  // Emit a signal to inform QML to reset game elements
}
