#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QTimer>

class GameController : public QObject
{
    Q_OBJECT
public:
    explicit GameController(QObject *parent = nullptr);

    Q_INVOKABLE void startGame();
    Q_INVOKABLE void stopGame(int scoreAchived);
    Q_INVOKABLE void restartGame();
    Q_INVOKABLE void gameReset();
    Q_INVOKABLE int getHighScore() const;

     void saveScore(int score);            // Save score to the database

signals:
    void gameOver();
    void updateScore(int score);
    void gameResetSignal();  // Signal to notify QML to reset game elements

private:
    int score;
    QSqlDatabase db;                      // Database object
     void setupDatabase();                 // Method to set up the database
};

#endif // GAMECONTROLLER_H
