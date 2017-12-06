//
//  MainViewController.swift
//  Igulim
//
//  Created by Elkana Orbach on 08/11/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import UIKit

class MainViewController: UIViewController
{
    var circlePerim: CGFloat = 0
    var circleSize = CGSize.zero
    let WinScore = 5
   
    var xPos = CGFloat()
    var yPos = CGFloat()
    
    var currentCircleFrame: CGRect = .zero
    var currentCircleColor = UIColor()
    
    var isRunning = true
    var playerOneScore = 0
    var playerTwoScore = 0
   
    
    let colors: [UIColor] = [.igulimPurple,
                             .igulimRed,
                             .igulimBlue,
                             .igulimBrown,
                             .igulimGreen]
    
    @IBOutlet weak var playerOneView: UIView!
    {
        didSet
        {
            playerOneView.makeRound(withShadow: true)
            playerOneView.layer.shadowOpacity = 1.0
            playerOneView.layer.shadowRadius = 8
            playerOneView.layer.shadowColor = UIColor.black.cgColor
            playerOneView.layer.shadowOffset = CGSize(width: -3, height: 6)
        }
    }
    @IBOutlet weak var playerTwoView: UIView!
    {
        didSet
        {
            playerTwoView.makeRound(withShadow: true)
            playerTwoView.layer.shadowOpacity = 1.0
            playerTwoView.layer.shadowRadius = 8
            playerTwoView.layer.shadowColor = UIColor.black.cgColor
            playerTwoView.layer.shadowOffset = CGSize(width: -3, height: 6)
        }
    }
    @IBOutlet weak var playerTwoScoreLabel: UILabel!
    @IBOutlet weak var playerOneScoreLabel: UILabel!
    @IBOutlet weak var enoughButton: UIButton!
    {
        didSet
        {
            enoughButton.layer.cornerRadius = 8
            
        }
    }
    @IBOutlet weak var gameCourt: UIView!
        {
        didSet
        {
            gameCourt.layer.cornerRadius = 6
            gameCourt.layer.shadowOpacity = 0.4
            gameCourt.layer.shadowRadius = 10
            gameCourt.layer.shadowColor = UIColor.black.cgColor
            gameCourt.layer.shadowOffset = CGSize(width: 4, height: 4)
        }
    }
    @IBOutlet weak var winLabel: UILabel!

    fileprivate func restartGame()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UIButton)
    {
        restartGame()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        circlePerim = view.frame.width / 7.5
        circleSize = CGSize(width: circlePerim, height: circlePerim)
        
        let touchPane = UIView(frame: self.view.frame)
        touchPane.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(score)))
        view.insertSubview(touchPane, belowSubview: enoughButton)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        Optimove.sharedInstance.report(event: ScreenName(screenName: "game_screen") , completionHandler: nil)
        drawCircle()
    }
    
    private func updateUIScore()
    {
        playerTwoScoreLabel.text = String(playerTwoScore)
        playerOneScoreLabel.text = String(playerOneScore)
    }
    
    @objc func score(_ gestureRec: UITapGestureRecognizer)
    {
        if !isRunning
        {
            restartGame()
            return
        }
        
        let tapPos = gestureRec.location(in: self.view)
        let isInX = currentCircleFrame.origin.x <= tapPos.x && tapPos.x <= currentCircleFrame.origin.x + circleSize.width
        let isInY = currentCircleFrame.origin.y <= tapPos.y && tapPos.y <= currentCircleFrame.origin.y + circleSize.height
        if isInX && isInY
        {
            switch currentCircleColor
            {
            case .igulimPurple:
                playerTwoScore += 1
            case .igulimRed:
                playerOneScore += 1
            case .igulimBlue:
                fallthrough
            case .igulimBrown:
                fallthrough
            case .igulimGreen:
                playerTwoScore -= 3
                playerOneScore -= 3
            default:
                break
            }
            updateUIScore()
        }
         validateWinner()
        
        
    }
    
    fileprivate func validateWinner()
    {
        if playerOneScore >= WinScore
        {
            isRunning = false
            UIView.animate(withDuration: 0.4, animations:
                {
                    self.winLabel.text = "Player 1 win"
                    self.winLabel.textColor = UIColor.igulimRed
                    self.winLabel.isHidden = false
                    
            })
            return
        }
        
        if playerTwoScore >= WinScore
        {
            isRunning = false
            UIView.animate(withDuration: 0.4, animations:
                {
                    self.winLabel.text = "Player 2 win"
                    self.winLabel.textColor = UIColor.igulimPurple
                    self.winLabel.isHidden = false
            })
            return
        }
    }
}

//MARK: - Game UI Setup

extension MainViewController
{
    fileprivate func setCircleProperties( circle: UIView,  color: UIColor, size: CGSize)
    {
        circle.clipsToBounds = true
        circle.frame.size = .zero
        circle.backgroundColor = color
        circle.layer.cornerRadius = size.width / 2
        circle.isUserInteractionEnabled = true
    }
    
    //Game Loop
    func drawCircle()
    {
        if (!isRunning)
        {
            return
        }
        
        let color = self.generateRandomColor()
        let location = self.generateRandomLocation()
        
        let circle = UIView(frame: CGRect(origin: location, size: circleSize))
        setCircleProperties(circle: circle,
                            color: color,
                            size: circleSize)
        self.currentCircleColor = color
        self.currentCircleFrame = circle.frame
        
        view.insertSubview(circle, at: 4)
        
        UIView.animate(withDuration: 1.4, animations:
            {
                circle.frame.size = self.circleSize
        }) { _ in
            circle.removeFromSuperview()
            self.drawCircle()
        }
    }
}

//MARK: - Generators

extension MainViewController
{
    private func generateRandomLocation() -> CGPoint
    {
        xPos = (CGFloat(arc4random_uniform(UInt32((gameCourt.frame.width - circlePerim))))) + gameCourt.frame.origin.x
        yPos = (CGFloat(arc4random_uniform(UInt32((gameCourt.frame.height - circlePerim))))) + gameCourt.frame.origin.y
        return CGPoint(x: xPos, y: yPos)
    }
    
    private func generateRandomColor() -> UIColor
    {
        let index =  Int(arc4random_uniform(UInt32(colors.count)))
        return colors[index]
    }
    
    private func pickRandomLocation() -> CGPoint
    {
        return  CGPoint(x:Int(arc4random()%1000),
                        y:Int(arc4random()%1000))
    }
}

extension UIColor
{
    class var igulimPurple:UIColor
    {
        return UIColor(red: CGFloat(0.318),
                       green: CGFloat(0.176),
                       blue: CGFloat(0.659),
                       alpha: 1)
    }
    class var igulimRed:UIColor
    {
        return UIColor(red: CGFloat(0.957),
                       green: CGFloat(0.263),
                       blue: CGFloat(0.212),
                       alpha: 1)
    }
    class var igulimBlue:UIColor
    {
        return UIColor(red: CGFloat(0.098),
                       green: CGFloat(0.463),
                       blue: CGFloat(0.824),
                       alpha: 1)
    }
    class var igulimBrown:UIColor
    {
        return UIColor(red: CGFloat(0.365),
                       green: CGFloat(0.251),
                       blue: CGFloat(0.216),
                       alpha: 1)
    }
    class var igulimGreen:UIColor
    {
        return UIColor(red: CGFloat(0.804),
                       green: CGFloat(0.863),
                       blue: CGFloat(0.224),
                       alpha: 1)
    }
}

