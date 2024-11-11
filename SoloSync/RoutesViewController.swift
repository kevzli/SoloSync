import UIKit

class RoutesViewController: UIViewController {
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var theScroll: UIScrollView!
    @IBOutlet weak var Locs: UIStackView!
    @IBOutlet weak var theView: UIView!
    
    private let calR = CalRoute()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Locs.spacing = 10
        setView()
        addinit()
        setSort()
    }
    
    // Initially add start and end
    private func addinit() {
        let start = createLoc(title: "Start", placeholder: "Enter Start Location")
        let end = createLoc(title: "End", placeholder: "Enter End Location")
        Locs.addArrangedSubview(start)
        Locs.addArrangedSubview(end)
    }
    
    // Function to create a new location input
    private func createLoc(title: String, placeholder: String) -> LocFrameView {
        let loc = LocFrameView()
        loc.configure(title: title, placeholder: placeholder)
        return loc
    }
    
    // Action to add a new stop location
    @IBAction func AddLoc(_ sender: UIButton) {
        let index = Locs.arrangedSubviews.count - 1
        let stop = createLoc(title: "Stop \(index)", placeholder: "Enter Location")
        
        stop.deleteAction = { [weak self, weak stop] in
            guard let self = self, let stop = stop else { return }
            self.Locs.removeArrangedSubview(stop)
            stop.removeFromSuperview()
        }
        
        Locs.insertArrangedSubview(stop, at: index)
    }
    
    // Set constraints for the main view and stack view
    private func setView() {
        theView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theView.leadingAnchor.constraint(equalTo: theScroll.contentLayoutGuide.leadingAnchor),
            theView.trailingAnchor.constraint(equalTo: theScroll.contentLayoutGuide.trailingAnchor),
            theView.topAnchor.constraint(equalTo: theScroll.contentLayoutGuide.topAnchor),
            theView.bottomAnchor.constraint(equalTo: theScroll.contentLayoutGuide.bottomAnchor),
            theView.widthAnchor.constraint(equalTo: theScroll.frameLayoutGuide.widthAnchor)
        ])
        
        Locs.alignment = .fill
        Locs.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            Locs.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            Locs.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            Locs.topAnchor.constraint(equalTo: theView.topAnchor, constant: 20)
        ])
        
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addBtn.topAnchor.constraint(equalTo: Locs.bottomAnchor, constant: 20),
            addBtn.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            addBtn.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16)
        ])
    }
    
    // Initialize the sort segmented control
    let sort_arr: UISegmentedControl = {
        let its = UISegmentedControl(items: ["Rating", "Popularity", "Category"])
        its.selectedSegmentIndex = 0
        its.translatesAutoresizingMaskIntoConstraints = false
        return its
    }()
    //label to display the est time
    let est: UILabel = {
        let l = UILabel()
        l.text = "Estimated Time: 1h 50m"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    //recommendation btn, call func to calculate the route
    let recBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Show Rec Route", for: .normal)
        btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    //stackview of 4 btns on the bottom
    let btns = RouteBtns()
    
    // Set constraints for the sort segmented control
    private func setSort() {
        theView.addSubview(sort_arr)
        theView.addSubview(est)
        theView.addSubview(recBtn)
        theView.addSubview(btns)
        
        NSLayoutConstraint.activate([
            //sort constraint
            sort_arr.topAnchor.constraint(equalTo: addBtn.bottomAnchor, constant: 40),
            sort_arr.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            sort_arr.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            
            //est time constraint
            est.topAnchor.constraint(equalTo: sort_arr.bottomAnchor, constant: 20),
            est.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            est.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            //recommend btn constraint
            recBtn.topAnchor.constraint(equalTo: est.bottomAnchor, constant: 30),
            recBtn.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 116),
            recBtn.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -116),
            recBtn.heightAnchor.constraint(equalToConstant: 44),
            //4 btns constraint
            btns.topAnchor.constraint(equalTo: recBtn.bottomAnchor, constant: 30),
            btns.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            btns.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            btns.bottomAnchor.constraint(equalTo: theView.bottomAnchor, constant: -20)
        ])
        
        recBtn.addTarget(self, action: #selector(cal), for: .touchUpInside)
    }
    //cal to calculate estimate time of the route
    @objc private func cal() {
        //acquire start and end point
        guard let s = Locs.arrangedSubviews.first as? LocFrameView,
              let e = Locs.arrangedSubviews.last as? LocFrameView else {
            est.text = "N/A"
            return
        }
        
        let start = s.t.text ?? ""
        let end = e.t.text ?? ""
        //check if there are stops, if there are, pass to CalRoute as an array
        //first ignore the 1st and last stackview
        let vs = Locs.arrangedSubviews

        let vs2 = Array(vs.dropFirst())
        let a_stp = Array(vs2.dropLast())
        
        var stops: [String] = []
        
        //get text
        for i in a_stp {
            if let locView = i as? LocFrameView {
                let text = locView.t.text ?? ""
                if !text.isEmpty {
                    stops.append(text)
                }
            }
        }
        if start.isEmpty || end.isEmpty {
            est.text = "Enter start/end locations"
            return
        }

        //show the time if get result, show N/A if failed
        calR.calt(start: start, end: end, stops: stops) { [weak self] ef in
            DispatchQueue.main.async {
                self?.est.text = "Estimated Time: \(ef ?? "N/A")"
            }
        }
    }
}
