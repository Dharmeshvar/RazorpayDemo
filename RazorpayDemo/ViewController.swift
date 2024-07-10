import UIKit
import Razorpay

class ViewController: UIViewController {
  
    @IBOutlet weak var amountText: UITextField!
    
    private let testkey = "rzp_test_eW9ICD3cvAUMFL"

        var razorpay: RazorpayCheckout!
        override func viewDidLoad() {
            super.viewDidLoad()
            razorpay = RazorpayCheckout.initWithKey(testkey, andDelegate: self)
        }
       
    @IBAction func pay(_ sender: Any) {
        guard let amountFetch = amountText.text, !amountFetch.isEmpty else {
            print("Please enter correct ammount first")
            return
        }
        
        if let amountGet = Int(amountFetch), amountGet > 0 {
                    let convertIndianMoney = amountGet * 100 // This is in currency subunits. 100 = 100 paise = INR 1.
                    self.getOrderID(amount: convertIndianMoney)
        } else {
            print("Amount should be greater than zero.")
        }
    }
    
    func getOrderID(amount: Int) {
            guard let url = URL(string: "http://localhost/Razorpay/Razorpay.php?amount=\(amount)") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let orderId = json["order_id"] as? String {
                            DispatchQueue.main.async {
                                self.showPaymentForm(amount: String(amount), orderId: orderId)
                            }
                        } else if let error = json["error"] as? String {
                            print("Error: \(error)")
                        }
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            task.resume()
        }
    
    private func showPaymentForm(amount: String, orderId: String) {
           let options: [String: Any] = [
               "key": testkey,
               "amount": amount,
               "currency": "INR",
               "description": "purchase description",
               "order_id": orderId, // Order ID from your PHP server
               "image": "https://url-to-image.jpg",
               "name": "business or product name",
               "prefill": [
                   "contact": "9797979797",
                   "email": "foo@bar.com"
               ],
               "theme": [
                   "color": "#F37254"
               ]
           ]
           razorpay.open(options)
       }
}

extension ViewController: RazorpayPaymentCompletionProtocol {
    func onPaymentError(_ code: Int32, description str: String) {
        // Handle payment error
        let alert = UIAlertController(title: "Payment Failed", message: str, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        // Handle payment success
        amountText.text = ""
        let alert = UIAlertController(title: "Payment Successful", message: "Payment ID: \(payment_id)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        amountText.text = ""
    }
}
