import UIKit

class LocFrameView: UIView {
    //title
    let l: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        l.textColor = UIColor.black
        return l
    }()
    //input field with formating
    let t: UITextField = {
        let t = UITextField()
        t.backgroundColor = UIColor(white: 0.97, alpha: 0.9)
        t.layer.cornerRadius = 8.5
        t.borderStyle = .none
        t.textAlignment = .left
        t.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        t.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: t.frame.height))
        t.leftViewMode = .always
        return t
    }()
    
    private let st = UIStackView()
    var deleteAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        load()
    }
    //inner space format
    private func load() {
        st.axis = .vertical
        st.spacing = 7
        st.addArrangedSubview(l)
        st.addArrangedSubview(t)
        
        addSubview(st)
        st.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            st.topAnchor.constraint(equalTo: self.topAnchor),
            st.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            st.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            st.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        t.heightAnchor.constraint(equalToConstant: 42).isActive = true
        //allow delete if left swipe
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(sw))
        swipe.direction = .left
        addGestureRecognizer(swipe)
        
    }
    
    func configure(title: String, placeholder: String) {
        l.text = title
        t.placeholder = placeholder
    }
    @objc private func sw() {
            if l.text?.contains("Stop") == true {
                deleteAction?()
            }
        }

}
