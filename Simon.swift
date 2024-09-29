import UIKit



class frontViewController: UIViewController {

    

    @IBOutlet weak var pic: UIImageView!

    



    @IBOutlet weak var play: UIButton!

    

    

    @IBAction func pressedplay(_ sender: Any) {

        

        

        //performSegue(withIdentifier: showdetail, sender:self )

    }

    

    

    override func viewDidLoad() {

        super.viewDidLoad()

        pic.image = UIImage(named: "yourImageName")

        // Do any additional setup after loading the view.

    }

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "todetail" {

            

        }

    }    /*

    // MARK: - Navigation



    // In a storyboard-based application, you will often want to do a little preparation before navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get the new view controller using segue.destination.

        // Pass the selected object to the new view controller.

    }

    */



}


//

//  ViewController.swift

//  app

//

//  Created by Xu, Yanqi on 01/11/2023.

//





import UIKit

import AVFoundation

import CoreData







class ViewController: UIViewController {

    

    @IBOutlet weak var roundLabel: UILabel!

    

    @IBOutlet weak var SCORE: UILabel!

    

    

    @IBOutlet weak var startButton: UIButton!

    

    @IBOutlet weak var redButton: UIButton!

    

    @IBOutlet weak var yellowButton: UIButton!

    

    @IBOutlet weak var blueButton: UIButton!

    

    @IBOutlet weak var greenButton: UIButton!

    

    @IBOutlet weak var highscores: UIButton!

    

    @IBAction func highscores(_ sender: Any) {

        performSegue(withIdentifier: "showHighScores", sender: self)

        

      

    }

    

   

    var isMultiplayerMode = false

    

    

    var gameHasStarted: Bool = false



    var sequence = [Int]()

    var currentStep = 0

    var score = 0

    var playerSequence = [Int]()

    var audioPlayer: AVAudioPlayer?

    var audioClips: [String: URL] = [:]

    

    var currentRound = 1

    var isPlayingSequence = false

    

    override func viewDidLoad() {

        super.viewDidLoad()

        audioClips = getAllMP3FileNameURLs()

        

        roundLabel.layer.borderWidth = 1.0

        

        roundLabel.layer.borderColor = UIColor.black.cgColor

        

       

    }

    

    

    @IBAction func multiplayermode(_ sender: Any) {

        startMultiplayerGame()

       }

    

    

    

    var players: [Player] = []

        var currentPlayerIndex = 0



       

        struct Player {

            var name: String

            var score: Int = 0

        }

    

    

   



   

    func startMultiplayerGame() {

        let alertController = UIAlertController(title: "Multiplayer Mode", message: "Enter player details", preferredStyle: .alert)



        alertController.addTextField { textField in

            textField.placeholder = "Number of players (max 5)"

            textField.keyboardType = .numberPad

        }



        

        for _ in 1...5 {

            alertController.addTextField { textField in

                textField.placeholder = "Player name"

                textField.isEnabled = false

            }

        }



        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in

            guard let textFields = alertController.textFields, let numberOfPlayersString = textFields[0].text, let numberOfPlayers = Int(numberOfPlayersString), numberOfPlayers > 0, numberOfPlayers <= 5 else {

                return

            }



           

            let playerNames = textFields[1...numberOfPlayers].compactMap { $0.text?.isEmpty == false ? $0.text : nil }



           

            if playerNames.count == numberOfPlayers {

                self?.setupMultiplayerGame(with: playerNames)

            }

        }



        alertController.addAction(confirmAction)



       

        alertController.textFields?[0].addTarget(self, action: #selector(playerNumberChanged(_:)), for: .editingChanged)



        present(alertController, animated: true)

    }



   

    @objc func playerNumberChanged(_ textField: UITextField) {

        if let alert = presentedViewController as? UIAlertController, let textFields = alert.textFields {

            if let numberOfPlayersString = textField.text, let numberOfPlayers = Int(numberOfPlayersString), numberOfPlayers > 0, numberOfPlayers <= 5 {

                for i in 1...5 {

                    textFields[i].isEnabled = i <= numberOfPlayers

                }

            } else {

                for i in 1...5 {

                    textFields[i].isEnabled = false

                }

            }

        }

    }



    // 设置多人游戏

    func setupMultiplayerGame(with playerNames: [String]) {

        isMultiplayerMode = true

            players = playerNames.map { Player(name: $0, score: 0) }

            currentPlayerIndex = 0

            startNewRoundForCurrentPlayer()

        }

    func startNewRoundForCurrentPlayer() {

            let currentPlayer = players[currentPlayerIndex]

            SCORE.text = "\(currentPlayer.name)'s Turn"

            startNewGame()

        }





   

   



    

    

    func getAllMP3FileNameURLs() -> [String: URL] {

        var audioFiles: [String: URL] = [:]

        let fileManager = FileManager.default

        let bundleURL = Bundle.main.bundleURL

        let assetURLs = try? fileManager.contentsOfDirectory(at: bundleURL,

                                                             includingPropertiesForKeys: nil,

                                                             options: .skipsHiddenFiles)

        for url in assetURLs ?? [] {

            if url.pathExtension == "mp3" {

                let fileName = url.deletingPathExtension().lastPathComponent

                audioFiles[fileName] = url

            }

        }

        return audioFiles

        

    }

    

    func startNewGame() {

        sequence = (0..<10).map { _ in Int.random(in: 0...3) }

        currentRound = 1

        score = 0

        SCORE.text = "Score: \(score)"

        roundLabel.text = "Round: \(currentRound)"

        startButton.isEnabled = false

        

        gameHasStarted = true

       

        playSequence()

    }

    

    

    

    

    

    

    

    

    func playSequence() {

        isPlayingSequence = true

        currentStep = 0

        playerSequence = []

        

        let sequenceToPlay = Array(sequence.prefix(currentRound))

        

        for (index, color) in sequenceToPlay.enumerated() {

            let delay = Double(index) * 1.0

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                self.activateButton(at: color)

                if index == sequenceToPlay.count - 1 {

                    self.isPlayingSequence = false

                }

            }

        }

    }

    

    

    func activateButton(at index: Int) {

        let button: UIButton?

        let color: String

        switch index {

        case 0:

            button = redButton

            color = "red"

        case 1:

            button = yellowButton

            color = "yellow"

        case 2:

            button = blueButton

            color = "blue"

        case 3:

            button = greenButton

            color = "green"

        default:

            return

        }

        

        if let button = button {

            UIView.animate(withDuration: 0.2,

                           animations: {

                button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

            }, completion: { _ in

                UIView.animate(withDuration: 0.2) {

                    button.transform = CGAffineTransform.identity

                }

            })

            

            playSound(for: color)

        }

    }

    

    func playSound(for color: String) {

        

        

        do {

            if let url = audioClips[color] {

                let audioPlayer = try AVAudioPlayer(contentsOf: url)

                self.audioPlayer = audioPlayer

                audioPlayer.prepareToPlay()

                audioPlayer.play()

            } else {

                print("URL not found for color: \(color)")

            }

        } catch {

            print("Failed to play audio for color: \(color), error: \(error)")

        }

    }

    

    

    

    @IBAction func redButtonPressed(_ sender: Any) {

        playerPressed(button: 0)

    }

    @IBAction func yellowButtonPressed(_ sender: Any) {

        playerPressed(button: 1)

    }

    @IBAction func blueButtonPressed(_ sender: Any) {

        playerPressed(button: 2)

    }

    @IBAction func greenButtonPressed(_ sender: Any) {

        playerPressed(button: 3)

    }

    

    

    

    @IBAction func startGameButtonPressed(_ sender: UIButton) {

        startNewGame()

    }

    

    

    

    

    

    

    func playerPressed(button: Int) {

        

        

        if !gameHasStarted {

            return

        }

        if isPlayingSequence {

            

            return

        }

        playerSequence.append(button)

        if playerSequence.last != sequence[currentStep] {

            

            

            gameOver(withScore: Int64(score))

            return

        }

        if playerSequence.count == currentRound {

            

            score += currentRound

            SCORE.text = "score: \(score)"

            

            sequence.append(contentsOf: (0..<5).map { _ in Int.random(in: 0...3) })

            currentRound += 1

            roundLabel.text = "round: \(currentRound)"

            

            

            playSequence()

        } else {

            

            currentStep += 1

        }

    }

    

    

    

    

    

    



    func saveScore(score: Int64) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {

            return

        }

        

        let managedContext = appDelegate.persistentContainer.viewContext

        let highScore = NSEntityDescription.insertNewObject(forEntityName: "HighScore", into: managedContext) as! HighScore

        

        highScore.setValue(score, forKey: "score")

        highScore.setValue(Date(), forKey: "date")

        

        do {

            try managedContext.save()

        } catch let error as NSError {

            print("Could not save the score. \(error), \(error.userInfo)")

        }

    }



    func fetchTopScores(limit: Int = 6) -> [HighScore] {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {

            return []

        }

        

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<HighScore>(entityName: "HighScore")

        

        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchRequest.fetchLimit = limit

        

        do {

            let topScores = try managedContext.fetch(fetchRequest)

            return topScores

        } catch let error as NSError {

            print("Could not fetch scores. \(error), \(error.userInfo)")

            return []

        }

    }



    



   

    

    

    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showHighScores" {

            if let highScoresVC = segue.destination as? HighScoresViewController {

                highScoresVC.highScores = fetchTopScores()

            }

        }

    }



   

    func gameOver(withScore score: Int64) {

            if isMultiplayerMode {

                

                handleMultiplayerGameOver(withScore: score)

            } else {

                

                handleSinglePlayerGameOver(withScore: score)

            }

        }



        

    

func handleMultiplayerGameOver(withScore score: Int64) {

    players[currentPlayerIndex].score = Int(score)

    currentPlayerIndex += 1



    if currentPlayerIndex < players.count {

        showNextPlayerAlert()

    } else {

        showFinalScores()

        isMultiplayerMode = false

    }

}



func showFinalScores() {

   

    if let highestScoringPlayer = players.max(by: { $0.score < $1.score }) {

        saveScore(score: Int64(highestScoringPlayer.score))

    }



    let scoresMessage = players.map { "\($0.name): \($0.score)" }.joined(separator: "\n")

    let alert = UIAlertController(title: "Final Scores", message: scoresMessage, preferredStyle: .alert)

    alert.addAction(UIAlertAction(title: "OK", style: .default))

    present(alert, animated: true)



    players = []

    currentPlayerIndex = 0

}





        func handleSinglePlayerGameOver(withScore score: Int64) {

            gameHasStarted = false

            saveScore(score: score)

           // showHighScores()

            SCORE.text = "Game Over! Final Score: \(score)"

            startButton.isEnabled = true

        }



        func showNextPlayerAlert() {

            let nextPlayer = players[currentPlayerIndex]

            let alert = UIAlertController(title: "Next Player", message: "\(nextPlayer.name), it is your turn!", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in

                self?.startNewRoundForCurrentPlayer()

            })

            present(alert, animated: true)

        }

    

    

 

    

    func endGame() {

        

        gameOver(withScore: Int64(score))

    }

        

        

        

    }

    

    

    




//

//  highscoretableViewController.swift

//  app

//

//  Created by Xu, Yanqi on 10/11/2023.

//



import UIKit

import CoreData



class HighScoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    

    



 

    

    @IBOutlet weak var tableview: UITableView!

    

   

    var highScores: [HighScore] = []



    override func viewDidLoad() {

        super.viewDidLoad()

        tableview.dataSource = self

        tableview.delegate = self

        fetchHighScores()

    }



    

    func fetchHighScores() {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {

            return

        }



        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<HighScore>(entityName: "HighScore")



       

        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)

        fetchRequest.sortDescriptors = [sortDescriptor]



       

        fetchRequest.fetchLimit = 6



        do {

            highScores = try managedContext.fetch(fetchRequest)

            tableview.reloadData()

        } catch let error as NSError {

            print("error：\(error), \(error.userInfo)")

        }

    }







     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return highScores.count

    }

 

    

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HighScoreCell", for: indexPath)

        let highScore = highScores[indexPath.row]



        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium

        dateFormatter.timeStyle = .none



        

        let date = highScore.date ?? Date()

        let dateString = dateFormatter.string(from: date)

        cell.detailTextLabel?.text = "Date: \(dateString)"



        cell.textLabel?.text = "Score: \(highScore.score)"

        return cell

    }





   

}

