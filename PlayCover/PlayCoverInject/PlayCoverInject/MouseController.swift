
import GameController

class MouseController{
    
    static let shared = MouseController()

    private init() { }
    
    static func macClick(pressed: Bool){
            if(pressed){
                Recorder.shared.recordButton(point: overallMousePosition, phase: UITouch.Phase.began, tid: 2)
            } else{
                Recorder.shared.recordButton(point: overallMousePosition, phase: UITouch.Phase.ended, tid: 2)
            }
    }
    
    public static var overallMousePosition : CGPoint {
        var point = CGPoint(x: 0,y: 0)
        if #available(macOS 11, *) {
         point = Dynamic(InputController.window()?.nsWindow).mouseLocationOutsideOfEventStream.asCGPoint!
        }
        
        point.x = point.x * 1.3
        point.y = (InputController.screenHeight - point.y * 1.3)
        return point
    }
    
    public func setupMouse(){
        if let mouse = GCMouse.current {
            mouse.mouseInput?.mouseMovedHandler = {
                (mouse, deltaX, deltaY) in
                if(MouseEmitter.shared.active){
                    MouseEmitter.shared.update(deltaX: CGFloat(deltaX), deltaY: CGFloat(deltaY))
                }
            }
//            mouse.mouseInput?.leftButton.pressedChangedHandler = {
//                (mouse, delta, pressed) in
//                if pressed {
//                    MouseController.macClick(pressed: true)
//                } else{
//                    MouseController.macClick(pressed: false)
//                }
//            }
        }
    }
    
}

class MouseEmitter{
    
    static let shared = MouseEmitter()
    
    var centerX : CGFloat = 0
    var centerY : CGFloat = 0
    var size : CGFloat = 0
    var currentPosition : CGPoint = CGPoint(x: 0, y: 0)
    var active = false
    
    func reset(){
        if(active){
            self.currentPosition = CGPoint(x: centerX, y: centerY)
            self.setActive(active: false)
            self.setActive(active: true)
        }
    }
    
    func setup(size : CGFloat, centerX : CGFloat, centerY : CGFloat) {
        self.size = size
        self.centerX = centerX
        self.centerY = centerY
        self.currentPosition = CGPoint(x: centerX, y: centerY)
    }
    
    func update(deltaX : CGFloat, deltaY : CGFloat){
        if(!active) {return}
        currentPosition.y = currentPosition.y - deltaY
        currentPosition.x = currentPosition.x + deltaX
        Toucher.touch(point: currentPosition, phase: UITouch.Phase.moved, tid: 1)
    }

    func setActive(active : Bool){
        self.active = active
        if(active){
            Toucher.touch(point: CGPoint(x: centerX, y: centerY), phase: UITouch.Phase.began, tid: 1)
        } else{
            Toucher.touch(point: CGPoint(x: centerX, y: centerY), phase: UITouch.Phase.ended, tid: 1)
        }
    }
    
}

