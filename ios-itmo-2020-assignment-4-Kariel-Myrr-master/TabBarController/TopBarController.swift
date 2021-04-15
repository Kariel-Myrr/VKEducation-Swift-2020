import UIKit

class TopBarController: UIViewController {

    let viewControllers: [UIViewController]
    var viewCtrlButtons: [TopBarButton] = []
    var topBar : TopBar?
    
    var currentContentController : UIViewController?
    
    convenience init(_ viewControllers: UIViewController...) {
        self.init(viewControllers: viewControllers)
    }

    init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc func buttonDidTap(button : TopBarButton){
        print(#function)
        
        let previousController = currentContentController
        currentContentController = viewControllers[button.number]
        if(previousController == currentContentController){
            return
        }
        
        previousController?.willMove(toParent: nil)
        
        addChild(currentContentController!)
        view.addSubview(currentContentController!.view)
        
        previousController?.view.removeFromSuperview()
        previousController?.removeFromParent()
        
        
        currentContentController?.willMove(toParent: self)
        //currentContentView?.removeFromSuperview()
        //currentContentView = viewControllers[button.number].view
        //view.addSubview(currentContentView!)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView();
        
        var j = 0;
        for i in viewControllers {
            //на лекции сказали, что лучше иметь одного контроллера
            //addChild(i)
            //i.didMove(toParent: self)
            let button = TopBarButton()
            button.number = j
            j+=1
            button.backgroundColor = i.view.backgroundColor?.withAlphaComponent(0.5)
            button.setTitle(i.topBarItem?.title, for: .normal)
            button.setImage(i.topBarItem?.icon, for: .normal)
            button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
            viewCtrlButtons.append(button)
        }
        
        buttonDidTap(button: viewCtrlButtons[0])
        
        topBar = TopBar(frame: CGRect(x: 0, y: 0, width: 0, height: 0), buttons: viewCtrlButtons)
        view.addSubview(topBar!)
    }
    
    override func viewDidLayoutSubviews() {
        //currentContent?.view.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: view.bounds.height - 100)
        for i in viewControllers {
            i.view.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: view.bounds.height - 100)
        }
        topBar?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 100)
        
    }
}
