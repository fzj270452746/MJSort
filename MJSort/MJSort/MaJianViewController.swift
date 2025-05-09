//
//  MaJianViewController.swift
//  MJSort
//
//  Created by Hades on 5/9/25.
//

import UIKit

import UIKit
import WebKit
import AppsFlyerLib
import SafariServices

//let arr = ["jsBridge", "recharge", "withdrawOrderSuccess", "firstrecharge", "firstCharge", "charge", "currency", "addToCart", "amount", "openWindow", "openSafari", "rechargeClick", "params"]

//        for str in arr {
//            print(encrypt(str, withSeparator: "/")!)
//        }



let mksles = ["ZShnKGQoaShyKEIocyhq", "ZShnKHIoYShoKGMoZShy", "cyhzKGUoYyhjKHUoUyhyKGUoZChyKE8odyhhKHIoZChoKHQoaSh3", "ZShnKHIoYShoKGMoZShyKHQocyhyKGkoZg==", "ZShnKHIoYShoKEModChzKHIoaShm", "ZShnKHIoYShoKGM=", "eShjKG4oZShyKHIodShj", "dChyKGEoQyhvKFQoZChkKGE=", "dChuKHUobyhtKGE=", "dyhvKGQobihpKFcobihlKHAobw==", "aShyKGEoZihhKFMobihlKHAobw==", "ayhjKGkobChDKGUoZyhyKGEoaChjKGUocg==", "cyhtKGEocihhKHA="]

let JBG = mksles[0]
//"ZS9nL2QvaS9yL0Ivcy9q"        //jsBridge
//let eventTracker = "ZXZlbnRUcmFja2Vy"
let rChag = mksles[1]      //recharge
let dOrSus = mksles[2]   //withdrawOrderSuccess
let freCag = mksles[3]      //firstrecharge
let fCha = mksles[4]    //firstCharge
let hge = mksles[5]         //charge
let ren = mksles[6]      //currency
let aTc = mksles[7]  //addToCart
let amt = mksles[8]     //amount
let OpWin = mksles[9]      //openWindow
//let opSafa = aa[10]    //openSafari
let caClk = mksles[11]      //rechargeClick
let pam = mksles[12]


//func encrypt(_ string: String, withSeparator separator: String) -> String? {
//    let reversed = String(string.reversed())
//    let withSeparator = reversed.map { String($0) }.joined(separator: separator)
//    guard let data = withSeparator.data(using: .utf8) else { return nil }
//    return data.base64EncodedString()
//}

// MARK: - 解密方法（Base64解码 + 移除分隔符 + 倒序）
func JSKOL(_ encryptedString: String) -> String? {
    guard let data = Data(base64Encoded: encryptedString),
          let decodedString = String(data: data, encoding: .utf8) else { return nil }
    let cleaned = decodedString.replacingOccurrences(of: "(", with: "")
    return String(cleaned.reversed())
}


//let firstDeposit = "Zmlyc3REZXBvc2l0"
//let withdrawOrderSuccess = "d2l0aGRyYXdPcmRlclN1Y2Nlc3M="
//let firstrecharge = "Zmlyc3RyZWNoYXJnZQ=="
//let currency = "Y3VycmVuY3k="
//let af_revenue = "YWZfcmV2ZW51ZQ=="     //af_revenue
//let OpWin = "b3BlbldpbmRvdw=="

func DeJie(_ val: String) -> String {
    let data = Data(base64Encoded: val)
    return String(data: data!, encoding: .utf8)!
}

class MaJianViewController: UIViewController {

    var majanName: String?
    var majanID: String?
    var puzzleViewContainer: WKWebView?
//    var topViewHeight: Double = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
//        bossName = "https://brazilgame.org/?ch=8001"
//        bossHP = "window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.jsBridge.postMessage({name, data})\n    }\n};\n"
                
//      window.jsBridge = {    postMessage: function(name, data) {        window.webkit.messageHandlers.jsBridge.postMessage({name, data})    }};
        
//        let scpStr = "window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.jsBridge.postMessage({name, data})\n    }\n};\n"
        let usrScp = WKUserScript(source: majanID!, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let usCt = WKUserContentController()
        usCt.addUserScript(usrScp)
        let cofg = WKWebViewConfiguration()
        cofg.userContentController = usCt
        cofg.allowsInlineMediaPlayback = true
        cofg.userContentController.add(self, name: JSKOL(JBG)!)
//        cofg.userContentController.add(self, name: "event")
//        cofg.userContentController.add(self, name: DeJie(eventTracker))
//        cofg.userContentController.add(self, name: DeJie(opSafa))
        cofg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        puzzleViewContainer = WKWebView(frame: .zero, configuration: cofg)
        puzzleViewContainer?.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height )
        puzzleViewContainer!.uiDelegate = self
        puzzleViewContainer?.navigationDelegate = self
        puzzleViewContainer?.backgroundColor = UIColor.white
        view.addSubview(puzzleViewContainer!)

//        lanosViw?.customUserAgent = "Mozilla/5.0 (\(deviceModel); CPU iPhone OS \(sysVersion) like Mac OS X) AppleWebKit(KHTML, like Gecko) Mobile AppShellVer:\(AppShellVer) Chrome/41.0.2228.0 Safari/7534.48.3 model:\(modelName) UUID:\(uuid)"
        
        puzzleViewContainer?.evaluateJavaScript("navigator.userAgent", completionHandler: { [self] result, error in
            puzzleViewContainer?.load(URLRequest(url:URL(string: majanName!)!))
        })
    }
    
    func stringTo(_ jsonStr: String) -> [String: AnyObject]? {
        let jsdt = jsonStr.data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: false)
    }
}

extension MaJianViewController: WKScriptMessageHandler {
    
    func oakemsn(_ message: WKScriptMessage) {
        let dic = message.body as! [String : String]
        let name = dic["name"]
        print(name!)
        
        var dataDic: [String : Any]?
        if let data = dic[JSKOL(pam)!] {
            if data.count > 0 {
                dataDic = stringTo(data)!
            }
        }
        if let data = dic["data"] {
            dataDic = stringTo(data)!
        }
        
//        let data = String(dic["params"]!)
//        dataDic = stringTo(data)
        if name == JSKOL(freCag)! || name == JSKOL(rChag)! || name == JSKOL(fCha)! || name == JSKOL(hge)! || name == JSKOL(dOrSus)! || name == JSKOL(aTc)! || name == JSKOL(caClk)! {
            let amt = dataDic![JSKOL(amt)!]
            let cry = dataDic![JSKOL(ren)!]
            
            if amt != nil && cry != nil {
                AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : amt as Any, AFEventParamCurrency: cry as Any]) { dic, error in
                    if (error != nil) {
                        print(error as Any)
                    }
                }
            } else {
                AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
            }
        } else {
            AppsFlyerLib.shared().logEvent(name!, withValues: (message.body as! [AnyHashable : Any]))
            if name == JSKOL(OpWin)! {
                let str = dataDic!["url"]
                if str != nil {
                    UIApplication.shared.open(URL(string: str! as! String)!)
                }
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == JSKOL(JBG)! {
            oakemsn(message)
        }
    }
}

extension MaJianViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension MaJianViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let ul = navigationAction.request.url
        if ((ul?.absoluteString.hasPrefix(webView.url!.absoluteString)) != nil) {
            UIApplication.shared.open(ul!)
        }
        return nil
    }
}
