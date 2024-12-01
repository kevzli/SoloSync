import UIKit

class RoutesViewController: UIViewController {
    
    private let theScroll = UIScrollView()
    private let theView = UIView()
    private let Locs = UIStackView()
    private let addBtn = UIButton(type: .system)
    private let recBtn = UIButton(type: .system)
    private let btns = RouteBtns()
    private let calR = CalRoute()
    
    //init func
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupMain()
        setupStackView()
        setupAddBtn()
        setupBtns()
        addInit()
    }
    
    //make it scroll!!!
    private func setupScrollView() {
        theScroll.bounces = true
        theScroll.alwaysBounceVertical = true
        theScroll.translatesAutoresizingMaskIntoConstraints = false
        theScroll.isScrollEnabled = true
        
        view.addSubview(theScroll)
        
        NSLayoutConstraint.activate([
            theScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            theScroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            theScroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            theScroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    //add a subview to scroll, so that there's content to adjust
    private func setupMain() {
        theView.translatesAutoresizingMaskIntoConstraints = false
        theScroll.addSubview(theView)
        NSLayoutConstraint.activate([
            theView.topAnchor.constraint(equalTo: theScroll.contentLayoutGuide.topAnchor),
            theView.bottomAnchor.constraint(equalTo: theScroll.contentLayoutGuide.bottomAnchor),
            theView.widthAnchor.constraint(equalTo: theScroll.frameLayoutGuide.widthAnchor),
            theView.leadingAnchor.constraint(equalTo: theScroll.contentLayoutGuide.leadingAnchor),
            theView.trailingAnchor.constraint(equalTo: theScroll.contentLayoutGuide.trailingAnchor),
        ])
    }
    //stack view contain the location info of start, end, stops... follow MVC
    private func setupStackView() {
        Locs.axis = .vertical
        Locs.spacing = 10
        Locs.alignment = .fill
        Locs.translatesAutoresizingMaskIntoConstraints = false
        theView.addSubview(Locs)
        NSLayoutConstraint.activate([
            Locs.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            Locs.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            Locs.topAnchor.constraint(equalTo: theView.topAnchor, constant: 20)
        ])
    }
    
    //AddBtn to add more stop, only layout here
    private func setupAddBtn() {
        addBtn.setTitle("Add Stop", for: .normal)
        addBtn.setTitleColor(.white, for: .normal)
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        addBtn.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
        
        theView.addSubview(addBtn)
        
        NSLayoutConstraint.activate([
            addBtn.topAnchor.constraint(equalTo: Locs.bottomAnchor, constant: 20),
            addBtn.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            addBtn.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16)
        ])
    }
    
    //layout of the Cal btn
    private func setupBtns() {
        recBtn.setTitle("Show Rec Route", for: .normal)
        recBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        recBtn.setTitleColor(.white, for: .normal)
        recBtn.layer.cornerRadius = 8
        recBtn.translatesAutoresizingMaskIntoConstraints = false
        
        theView.addSubview(recBtn)
        theView.addSubview(btns)
        
        NSLayoutConstraint.activate([
            recBtn.topAnchor.constraint(equalTo: addBtn.bottomAnchor, constant: 30),
            recBtn.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 116),
            recBtn.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -116),
            recBtn.heightAnchor.constraint(equalToConstant: 44),
            
            btns.topAnchor.constraint(equalTo: recBtn.bottomAnchor, constant: 30),
            btns.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            btns.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            btns.bottomAnchor.constraint(equalTo: theView.bottomAnchor, constant: -20)
        ])
        
        //bind btns to func
        btns.s.addTarget(self, action: #selector(sv), for: .touchUpInside)
        btns.share.addTarget(self, action: #selector(share), for: .touchUpInside)
        recBtn.addTarget(self, action: #selector(calc), for: .touchUpInside)
    }
    
    //add init loc, start and end
    private func addInit() {
        let g = CAGradientLayer()
        g.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        g.startPoint = CGPoint(x: 0, y: 0)
        g.endPoint = CGPoint(x: 1, y: 1)
        g.frame = view.bounds
                
        let bg = UIView(frame: view.bounds)
        bg.layer.addSublayer(g)
        view.addSubview(bg)
        view.sendSubviewToBack(bg)
        let start = c(title: "Start", placeholder: "Enter Start Location")
        let end = c(title: "End", placeholder: "Enter End Location")
        Locs.addArrangedSubview(start)
        Locs.addArrangedSubview(end)
    }
    
    //add stop
    private func c(title: String, placeholder: String) -> LocFrameView {
        let loc = LocFrameView()
        loc.configure(title: title, placeholder: placeholder)
        return loc
    }
    
    //func to add more stop
    @objc private func addLocation() {
        let index = Locs.arrangedSubviews.count - 1
        let stop = c(title: "Stop \(index)", placeholder: "Enter Location")
        
        stop.deleteAction = { [weak self, weak stop] in
            guard let self = self, let stop = stop else { return }
            self.Locs.removeArrangedSubview(stop)
            stop.removeFromSuperview()
        }
        
        Locs.insertArrangedSubview(stop, at: index)
    }
    
    @objc private func calc() {
        calcc()
    }
    
    //cal route based on google api
    private func calcc() {
        guard let startView = Locs.arrangedSubviews.first as? LocFrameView,
              let endView = Locs.arrangedSubviews.last as? LocFrameView else {
            return
        }
        
        let start = startView.t.text ?? ""
        let end = endView.t.text ?? ""
        let stops = Locs.arrangedSubviews.dropFirst().dropLast().compactMap { view -> String? in
            guard let stopView = view as? LocFrameView else { return nil }
            return stopView.t.text?.isEmpty == false ? stopView.t.text : nil
        }
        
        if start.isEmpty || end.isEmpty {
            show(title: "Missing info", msg: "Please fill in all info")
            return
        }
        print("call")
        //get a long string, all info (start, end, description, est time) in one string
        calR.calt(start: start, end: end, stops: stops) { est, desc in
            DispatchQueue.main.async {
                if let est = est, let desc = desc{
                    let t = "\(start) -> \(end)"
                    let join = "\(t)\n\nEstimated Time: \(est)\n\nRoute Description:\n\(desc)"
                    let VC = RouteDetailViewController()
                    VC.des = join
                    self.navigationController?.pushViewController(VC, animated: true)
                }else{
                    self.show(title: "Error", msg: "No route found")
                }
            }
        }
    }
    
    private func show(title: String, msg: String) {
        let m = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        m.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(m, animated: true)
    }
    
    //jump to saved table
    @objc private func sv(){
        svtable()
    }
    
    //to share table
    @objc private func share(){
        let VC = ShareViewController()
        navigationController?.pushViewController(VC, animated: true)
    }
    
    //load usr default
    private func svtable(){
        let routes = UserDefaults.standard.array(forKey: "des") as? [[String: Any]] ?? []
        if routes.isEmpty {
            show(title:"Empty saved for now", msg:"add first")
            return
        }
        let VC = SavedViewController()
        VC.routes = routes
        navigationController?.pushViewController(VC, animated: true)
        
    }
}
