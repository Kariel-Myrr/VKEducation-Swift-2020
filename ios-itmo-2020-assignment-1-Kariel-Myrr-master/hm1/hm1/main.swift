//
//  main.swift
//  hm1
//
//  Created by Kariel Myrr on 22.09.2020.
//  Copyright © 2020 Kariel Myrr. All rights reserved.
//

import Foundation


class Casino { //казино тысячи и одной ночи
    
    static let AllCards = ["2" : 2,//матч на значения
        "3" : 3,
        "4" : 4,
        "5" : 5,
        "6" : 6,
        "7" : 7,
        "8" : 8,
        "9" : 9,
        "10" : 10,
        "jack" : 10,
        "qeen" : 10,
        "king" : 10,
        "ace" : -1]
    static let uniSym = ["2" : "\u{1F0A2}",//матч на красивые символы
        "3" : "\u{1F0A3}",
        "4" : "\u{1F0A4}",
        "5" : "\u{1F0A5}",
        "6" : "\u{1F0A6}",
        "7" : "\u{1F0A7}",
        "8" : "\u{1F0A8}",
        "9" : "\u{1F0A9}",
        "10" : "\u{1F0AA}",
        "jack" : "\u{1F0AB}",
        "qeen" : "\u{1F0AC}",
        "king" : "\u{1F0AD}",
        "ace" : "\u{1F0A1}"]
    
    static let toUni : (String) -> String = {return (uniSym[$0] ?? "err") + " "}
    
    enum GameStatus {
        case dealerWin
        case playerWin//can add (int) if players > 1
        case draw
        case pass
        case err(String)
    }
    
    struct CardDeck {//колоду храним только в виде массиве(а зачем что то большее)
        var deck : [String]
    }
    
    struct Hand {
        var value : Int//значение без тузов
        var cards : [String]//собственно карты
        var aceCounter : Int//количество тузов, чтоб удобней считать
        
        init() {
            value = 0
            cards = []
            aceCounter = 0
        }
        
        func chekForBlakJack () -> GameStatus {//чекаем на блэк джек, с остальным разберемся потом
            if(self.value + self.aceCounter * 11 == 21 || self.value + self.aceCounter == 21){
                return .playerWin
            }
            return .pass
        }
        
        func countScore() -> Int{//считаем макс возможную ценность ниже 21(не всегда ниже получается)
            return self.value + 11 * self.aceCounter <= 21 ? self.value + 11 * self.aceCounter : self.value + self.aceCounter
        }
    }
    
    class Dealer {
        
        var gameDeck : CardDeck
        var dealerHand = Hand()
        
        init() {//Дилер дурак, порядок другой. Но иначе заканчиваем блэк джеком  игрока
            gameDeck = CardDeck(deck: [])
            for _ in 1...4 {
                for i in 2...10 {
                    gameDeck.deck += ["\(i)"]
                }
                gameDeck.deck += ["ace", "jack", "king", "qeen"] //никто шафлить не просил :>
            }
        }
        
        init(deck: [String]) {
            gameDeck = CardDeck(deck: deck)
        }
        
        init(deck: CardDeck){
            gameDeck = deck
        }
        
        func startRound(playerHand : inout Hand) -> GameStatus{//начинаем раунд и чекаем на блэк джек
            var i : GameStatus = .err("err::no init for i")
            for _ in 1...2 {
                i = giveCard(playerHand: &playerHand)
                let _ = giveCard(playerHand: &dealerHand)
            }
            return i
        }
        
        func giveCard( playerHand : inout Hand) -> GameStatus{ //даем карту переданной нам руке, однако можем вернуть победа игрока, когда даем карту дилеру, но это нас не волнует
            guard !gameDeck.deck.isEmpty else {
                return .err("err::no cards in deck")
            }
            let card = gameDeck.deck.removeLast()
            if card == "ace" {
                playerHand.aceCounter += 1;
            } else {
                playerHand.value += AllCards[card] ?? 0//мы точно знаем, что card из колоды
            }
            
            playerHand.cards += [card]
            
            return playerHand.chekForBlakJack()
            
        }
        
        func pass(playerHand : Hand) -> GameStatus{//игрок пасанул, набираем дилером от 17
            let playerScore = playerHand.countScore()
            while(dealerHand.countScore() < 17){
                let _ = giveCard(playerHand: &dealerHand)
            }
            let dealerScore = dealerHand.countScore()
            if playerScore > 21 {
                return .dealerWin
            }
            if (dealerScore == playerScore){
                return .draw
            }
            if dealerScore > 21 {
                return .playerWin
            }
            return playerScore - dealerScore > 0 ? .playerWin : .dealerWin
        }
        
    }
    
    static func printGameStatusForPlayer(dealer: Dealer, playerHand: Hand){
        print("""
            Cards in deck: \(dealer.gameDeck.deck.count) \n
            Dealer have: \(dealer.dealerHand.cards.count) \n
            You have: \(playerHand.cards.count) \n
            Value of your cards: \(playerHand.value) + (aces)\(playerHand.aceCounter) \n
            Your hand : \(playerHand.cards.description)\n
            Your hand, but in cards: \(playerHand.cards.map(toUni).description) \n
            You can "take" or "pass" \n
            """)
    }
    
    static func printGameStatusForEnd(dealer: Dealer, playerHand : Hand){
        print("""
            Cards in deck: \(dealer.gameDeck.deck.count) \n
            Dealer have: \(dealer.dealerHand.cards.count) \n
            Dealer's hand : \(dealer.dealerHand.cards.description)\n
            Dealer's hand, but in cards: \(dealer.dealerHand.cards.map(toUni).description) \n
            You have: \(playerHand.cards.count) \n
            Your hand : \(playerHand.cards.description)\n
            Your hand, but in cards: \(playerHand.cards.map(toUni).description) \n
            You: \(playerHand.value) + (aces)\(playerHand.aceCounter)\n
            VS\n
            Dealer: \(dealer.dealerHand.value) + (aces)\(dealer.dealerHand.aceCounter) \n
            """)
    }
    
    
    static func playRoundOfBlackJack() -> GameStatus {//для будущего вынесли в метод
        let dealer = Dealer()
        var playerHand = Hand()
        let res = dealer.startRound(playerHand: &playerHand)
        switch res{
        case GameStatus.pass:
            break
        default:
            printGameStatusForPlayer(dealer: dealer, playerHand: playerHand)
            print("You have BlakJack. You won!")
            return res
        }
        var midRes : GameStatus
        while(true){
            printGameStatusForPlayer(dealer: dealer, playerHand: playerHand)
            let playerResponse = readLine()
            switch playerResponse {//пробегаемся по ответу игрока
            case "pass":
                midRes = dealer.pass(playerHand: playerHand)
            case "take":
                midRes = dealer.giveCard(playerHand: &playerHand)
            default:
                print("try again")
                continue
            }
            switch midRes {//пробегаемся по результату хода
            case .err:
                print("error in round")
            case .pass:
                continue
            case .draw:
                print("Draw\n")
            case .playerWin:
                print("You won\n")
            case .dealerWin:
                print("Dealer won\n")
            }
            printGameStatusForEnd(dealer: dealer, playerHand: playerHand)
            return midRes
        }
    }
    
}

//ура main

let _ = Casino.playRoundOfBlackJack()
//все сыро, но оснавная часть работает


