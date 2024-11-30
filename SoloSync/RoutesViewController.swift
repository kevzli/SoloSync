import UIKit

class RoutesViewController: UIViewController {
    
    private let theScroll = UIScrollView()
    private let theView = UIView()
    private let Locs = UIStackView()
    private let addBtn = UIButton(type: .system)
    private let sort_arr = UISegmentedControl(items: ["Rating", "Popularity", "Category"])
    private let est = UILabel()
    private let recBtn = UIButton(type: .system)
    private let btns = RouteBtns()
    private let calR = CalRoute()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupScrollView()
        setupMainView()
        setupStackView()
        setupAddButton()
        setupSortAndButtons()
        addInitialLocations()
    }
    
    private func setupScrollView() {
        theScroll.translatesAutoresizingMaskIntoConstraints = false
        theScroll.isScrollEnabled = true
        theScroll.bounces = true
        theScroll.alwaysBounceVertical = true
        view.addSubview(theScroll)
        
        NSLayoutConstraint.activate([
            theScroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            theScroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            theScroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            theScroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupMainView() {
        theView.translatesAutoresizingMaskIntoConstraints = false
        theScroll.addSubview(theView)
        
        NSLayoutConstraint.activate([
            theView.leadingAnchor.constraint(equalTo: theScroll.contentLayoutGuide.leadingAnchor),
            theView.trailingAnchor.constraint(equalTo: theScroll.contentLayoutGuide.trailingAnchor),
            theView.topAnchor.constraint(equalTo: theScroll.contentLayoutGuide.topAnchor),
            theView.bottomAnchor.constraint(equalTo: theScroll.contentLayoutGuide.bottomAnchor),
            theView.widthAnchor.constraint(equalTo: theScroll.frameLayoutGuide.widthAnchor)
        ])
    }
    
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
    
    private func setupAddButton() {
        addBtn.setTitle("Add Stop", for: .normal)
        addBtn.setTitleColor(.systemBlue, for: .normal)
        addBtn.addTarget(self, action: #selector(addLocation), for: .touchUpInside)
        addBtn.translatesAutoresizingMaskIntoConstraints = false
        theView.addSubview(addBtn)
        
        NSLayoutConstraint.activate([
            addBtn.topAnchor.constraint(equalTo: Locs.bottomAnchor, constant: 20),
            addBtn.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            addBtn.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSortAndButtons() {
        sort_arr.selectedSegmentIndex = 0
        sort_arr.translatesAutoresizingMaskIntoConstraints = false
        
        est.text = "Estimated Time: 1h 50m"
        est.textAlignment = .center
        est.translatesAutoresizingMaskIntoConstraints = false
        
        recBtn.setTitle("Show Rec Route", for: .normal)
        recBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        recBtn.setTitleColor(.white, for: .normal)
        recBtn.layer.cornerRadius = 8
        recBtn.addTarget(self, action: #selector(showRouteDetails), for: .touchUpInside)
        recBtn.translatesAutoresizingMaskIntoConstraints = false
        
        theView.addSubview(sort_arr)
        theView.addSubview(est)
        theView.addSubview(recBtn)
        theView.addSubview(btns)
        
        NSLayoutConstraint.activate([
            sort_arr.topAnchor.constraint(equalTo: addBtn.bottomAnchor, constant: 40),
            sort_arr.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            sort_arr.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            
            est.topAnchor.constraint(equalTo: sort_arr.bottomAnchor, constant: 20),
            est.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            est.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            
            recBtn.topAnchor.constraint(equalTo: est.bottomAnchor, constant: 30),
            recBtn.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 116),
            recBtn.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -116),
            recBtn.heightAnchor.constraint(equalToConstant: 44),
            
            btns.topAnchor.constraint(equalTo: recBtn.bottomAnchor, constant: 30),
            btns.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 16),
            btns.trailingAnchor.constraint(equalTo: theView.trailingAnchor, constant: -16),
            btns.bottomAnchor.constraint(equalTo: theView.bottomAnchor, constant: -20)
        ])
    }
    
    private func addInitialLocations() {
        let start = createLocationInput(title: "Start", placeholder: "Enter Start Location")
        let end = createLocationInput(title: "End", placeholder: "Enter End Location")
        Locs.addArrangedSubview(start)
        Locs.addArrangedSubview(end)
    }
    
    private func createLocationInput(title: String, placeholder: String) -> LocFrameView {
        let loc = LocFrameView()
        loc.configure(title: title, placeholder: placeholder)
        return loc
    }
    
    @objc private func addLocation() {
        let index = Locs.arrangedSubviews.count - 1
        let stop = createLocationInput(title: "Stop \(index)", placeholder: "Enter Location")
        
        stop.deleteAction = { [weak self, weak stop] in
            guard let self = self, let stop = stop else { return }
            self.Locs.removeArrangedSubview(stop)
            stop.removeFromSuperview()
        }
        
        Locs.insertArrangedSubview(stop, at: index)
    }
    
    @objc private func showRouteDetails() {
        calculateRoute { [weak self] estimatedTime in
            DispatchQueue.main.async {
                self?.est.text = "Estimated Time: \(estimatedTime ?? "N/A")"
            }
        }
    }

    
    private func calculateRoute(completion: @escaping (String?) -> Void) {
        guard let startView = Locs.arrangedSubviews.first as? LocFrameView,
              let endView = Locs.arrangedSubviews.last as? LocFrameView else {
            completion("N/A")
            return
        }
        
        let start = startView.t.text ?? ""
        let end = endView.t.text ?? ""
        let stops = Locs.arrangedSubviews.dropFirst().dropLast().compactMap { view -> String? in
            guard let stopView = view as? LocFrameView else { return nil }
            return stopView.t.text?.isEmpty == false ? stopView.t.text : nil
        }
        
        if start.isEmpty || end.isEmpty {
            completion("Enter start/end locations")
            return
        }
        
        calR.calt(start: start, end: end, stops: stops) { estimatedTime in
            completion(estimatedTime)
        }
    }

}
